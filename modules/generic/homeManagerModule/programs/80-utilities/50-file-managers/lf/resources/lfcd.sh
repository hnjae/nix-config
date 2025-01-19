#!/bin/sh

# TMPDIR="${TMPDIR:-/tmp}/lf"
# [ ! -d "${TMPDIR}" ] && mkdir -p "${TMPDIR}"

if command -v lf >/dev/null 2>&1; then
	lfcd() {
		tmp="$(mktemp --suffix="-lfcd")"
		# `command` is needed in case `lfcd` is aliased to `lf`
		command lf -last-dir-path="$tmp" "$@"
		if [ -f "$tmp" ]; then
			dir="$(cat "$tmp")"
			rm -f "$tmp"
			if [ -d "$dir" ]; then
				if [ "$dir" != "$(pwd)" ]; then
					cd "$dir" || return
				fi
			fi
		fi
	}
fi
