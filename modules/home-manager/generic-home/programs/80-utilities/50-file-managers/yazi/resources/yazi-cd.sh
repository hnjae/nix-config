#!/bin/sh

if command -v yazi >/dev/null 2>&1; then
  yazicd() {
    tmpdir="${TMPDIR:-/tmp}/yazi-${UID:-"$(id -u)"}"
    [ ! -d "${tmpdir}" ] && mkdir -p "${tmpdir}"

    tmp="$(mktemp -p "$tmpdir" --suffix=".yazi.cwd")"
    # `command` is needed in case something is aliased to `yazi`
    command yazi --cwd-file="$tmp" "$@"
    if [ -f "$tmp" ]; then
      if cwd="$(cat "$tmp")" && [ -n "$cwd" ] &&
        [ -d "$cwd" ] && [ "$cwd" != "${PWD:-$(pwd)}" ]; then
        cd -- "$cwd" || return
      fi
      rm -f -- "$tmp"
    fi
  }
fi
