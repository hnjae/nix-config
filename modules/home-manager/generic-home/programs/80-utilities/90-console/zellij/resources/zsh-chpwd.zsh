# https://www.reddit.com/r/zellij/comments/10skez0/comment/jrimomm/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

function zellij_tab_name_update() {
    if [ -n "$ZELLIJ" ]; then
        tab_name=''
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            # tab_name+=" "
            tab_name+="$(basename "$(git rev-parse --show-toplevel)")"/
            tab_name+="$(git rev-parse --show-prefix)"
            tab_name="${tab_name%/}"
        else
            tab_name="$PWD"
            if [ "$tab_name" = "$HOME" ]; then
                tab_name="~"
            else
                tab_name=${tab_name##*/}
            fi
        fi
        command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
    fi
}
zellij_tab_name_update
chpwd_functions+=(zellij_tab_name_update)
