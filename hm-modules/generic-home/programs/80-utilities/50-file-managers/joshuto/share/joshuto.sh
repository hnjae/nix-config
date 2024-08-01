#!/bin/sh

TMPDIR="${TMPDIR:-/tmp}/joshuto"
[ ! -d "${TMPDIR}" ] && mkdir -p "${TMPDIR}"

# Just joshuto wrapper
# NOTE: `type` is optional feature of POSIX-thing. use `command`.
if command -v joshuto >/dev/null 2>&1; then
	j() {
		# TODO: non-gnu/linux system? <2023-03-17>
		OUTPUT_FILE="$(mktemp --tmpdir="${TMPDIR}" --suffix="__joshuto-out")"
		joshuto --output-file "$OUTPUT_FILE" "$@"

		exit_code="$?"
		case "$exit_code" in
		0) ;;
		101)
			joshuto_cwd=$(cat "$OUTPUT_FILE")
			cd "$joshuto_cwd" || echo "cd failed"
			;;
		102) ;;
		*)
			echo "Joshuto exit code: $exit_code"
			;;
		esac

		rm -f "$OUTPUT_FILE"
	}
fi
