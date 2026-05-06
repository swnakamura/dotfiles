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
  # 通知用のエスケープシーケンス (OSC 777)
  local seq="\033]777;notify;${title};${msg}\007"

  # hook の stdout は Claude Code に吸われるので必ず TTY へ直接書く
  local out="${TTY:-/dev/tty}"

  if [ -n "$TMUX" ]; then
    # tmux内の場合：ラップして、内部の \033 を2重にする
    printf "\033Ptmux;\033${seq}\033\\" >"$out"
  else
    # tmux外の場合：そのまま送信
    printf "${seq}" >"$out"
  fi
}


TTY=$(find_tty)

# Stop hook は stdin で JSON を受け取る (cwd, transcript_path など)
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

project=$(basename "${cwd:-$PWD}")

# transcript (JSONL) から直近の assistant のテキスト発話を取り出す
summary=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  summary=$(jq -rs '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // ""' "$transcript" 2>/dev/null \
    | tr '\n' ' ' \
    | cut -c1-100)
fi

title="Claude Code [${project}]"
if [ -n "$summary" ]; then
  msg="$summary"
else
  msg="Stopped. Waiting for input."
fi

notify "$title" "$msg"
