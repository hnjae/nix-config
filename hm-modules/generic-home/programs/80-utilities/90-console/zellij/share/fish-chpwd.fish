# https://www.reddit.com/r/zellij/comments/10skez0/comment/kjtkxtu/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

function zellij_tab_name_update --on-variable PWD
    if set -q ZELLIJ
        set tab_name ''
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set git_root (basename (git rev-parse --show-toplevel))
            set git_prefix (git rev-parse --show-prefix)
            set tab_name "$git_root/$git_prefix"
            set tab_name (string trim -c / "$tab_name") # Remove trailing slash
        else
            set tab_name "$PWD"
            if test "$tab_name" = "$HOME"
                set tab_name "~"
            else
                set tab_name (basename "$tab_name")
            end
        end
        command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1 &
    end
end
