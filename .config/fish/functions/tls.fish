function tls --description "tmuxセッションをリストアップする。"
    set -l colwidth (tput cols)
    set -l colwidth (math "$colwidth - 10")
    set session_name (tmux display-message -p '#{session_name}')
    echo (set_color -o magenta)"Session: $session_name"(set_color normal)

    tmux list-windows -t "$session_name" -F "#{window_index} #{window_name}" | while read w_idx w_name
        echo "  " (set_color -o cyan)"Window $w_idx: $w_name"(set_color normal)

        tmux list-panes -t "$w_idx" -F "#{pane_index} #{pane_pid} #{pane_current_command}" | while read p_idx p_pid p_cmd
            set start_time (ps -p $p_pid -o lstart= | string trim)
            set full_cmd (ps --ppid $p_pid -o args= 2>/dev/null | string trim)
            set proc_start_time (ps --ppid $p_pid -o lstart= | head -n 1 | string trim)

            echo "       "(set_color blue)"Pane $p_idx"(set_color normal) \
                 "[PID: $p_pid]" \
                 (set_color green)" $start_time  (child process started at $proc_start_time)" (set_color normal)

            if test -z "$full_cmd"
                echo "          " "$p_cmd (idle)"(set_color normal)
            else if string match -q "*tmux: client*" "$full_cmd"
                printf "          "
                echo (set_color red)"[This Status Script]"(set_color normal)
            else
                set indent     "          "
                set indent_end "          "
                printf "          "
                echo "$full_cmd" | fmt -w $colwidth | sed "2,\$ {\$! s/^/$indent/}" | sed "\$ {1! s/^/$indent_end/}"
                printf (set_color normal)
            end
        end
    end
end
