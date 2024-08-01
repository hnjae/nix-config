#!/usr/bin/env fish

set tmp (mktemp --suffix="-yazicd")
# `command` is needed in case `yazicd` is aliased to `yazi`
command yazi --cwd-file="$tmp" $argv
if test -f "$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
