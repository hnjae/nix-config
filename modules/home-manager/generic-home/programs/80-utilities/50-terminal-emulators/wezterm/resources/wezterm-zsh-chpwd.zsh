#!/usr/bin/env bash

function wezterm_tab_name_update() {
    if [ "$TERM_PROGRAM" = "WezTerm" ] \
        && [ -z "$NVIM" ] \
        && [ -z "$ZELLIJ" ] \
        && [ -z "$TMUX" ] \
        && command -v wezterm >/dev/null 2>&1; then

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

        flatpak --user run org.wezfurlong.wezterm cli set-tab-title "$tab_name"
        # wezterm cli set-tab-title "$tab_name"
    fi
}

# wezterm_tab_name_update
chpwd_functions+=(wezterm_tab_name_update)
