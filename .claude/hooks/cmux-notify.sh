# Emit OSC 777 notification when Claude Code stops.
# Write to the TTY directly since hook stdout is captured by Claude Code.

find_tty() {
    local pid=$$
    for i in 1 2 3 4 5; do
        pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')
        [ -z "$pid" ] && return 1
        local tty
        tty=$(ps -p "$pid" -o tty= 2>/dev/null | tr -d ' ')
        if [ -n "$tty" ] && [ "$tty" != "?" ]; then
            echo "/dev/$tty"
            return 0
        fi
    done
    return 1
}

notify() {
  local title="$1"
  local msg="$2"
  # Escape sequence for notification (OSC 777)
  local seq="\033]777;notify;${title};${msg}\007"

  # hook stdout is captured by Claude Code, so always write directly to the TTY
  local out="${TTY:-/dev/tty}"

  if [ -n "$TMUX" ]; then
    # tmux passthrough (embedding into the pane's output) only reaches the outer
    # terminal when the window containing that pane is in the foreground
    # (it is lost on a different window/pane or when another window is fullscreen).
    # Instead, write the OSC directly to the attached client's real tty, bypassing
    # pane multiplexing. This delivers regardless of which window is in front.
    # Direct write means no tmux wrapping is needed.
    local clients
    clients=$(tmux list-clients -F '#{client_tty}' 2>/dev/null)
    if [ -n "$clients" ]; then
      local ct
      for ct in $clients; do
        printf "${seq}" >"$ct" 2>/dev/null
      done
    else
      # When detached: no target client exists. Fall back to the original tty.
      # (If fully detached, delivery is left to the push-notification side.)
      printf "${seq}" >"$out"
    fi
  else
    # Outside tmux: send as-is
    printf "${seq}" >"$out"
  fi
}


TTY=$(find_tty)

# Stop / Notification hooks receive JSON on stdin (cwd, transcript_path, message, etc.)
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')
event=$(printf '%s' "$input" | jq -r '.hook_event_name // ""')
message=$(printf '%s' "$input" | jq -r '.message // ""')

project=$(basename "${cwd:-$PWD}")

title="Claude Code [${project}]"

if [ "$event" = "Notification" ]; then
  # The Notification hook puts content like "waiting for permission/input" in .message
  if [ -n "$message" ]; then
    msg="$message"
  else
    msg="Waiting for your input."
  fi
else
  # Stop hook: extract the most recent assistant text utterance from the transcript (JSONL)
  summary=""
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    summary=$(jq -rs '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // ""' "$transcript" 2>/dev/null \
      | tr '\n' ' ' \
      | cut -c1-100)
  fi
  if [ -n "$summary" ]; then
    msg="$summary"
  else
    msg="Stopped. Waiting for input."
  fi
fi

notify "$title" "$msg"
