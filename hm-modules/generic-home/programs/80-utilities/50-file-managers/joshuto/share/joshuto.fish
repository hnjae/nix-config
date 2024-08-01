#!/usr/bin/env fish
# TODO: fix this <2023-03-22 >

# [ ! -d "${TMPDIR}" ] && mkdir "${TMPDIR}"

# Just joshuto wrapper

if command -v joshuto >/dev/null 2>&1
    function j
        # TODO: non-gnu/linux system? <2023-03-17>
        set OUTPUT_FILE "$(mktemp --tmpdir="/tmp/$USER" --suffix="__joshuto-out")"

        joshuto --output-file "$OUTPUT_FILE" "$argv"

        set exit_code "$status"
        switch "$exit_code"
            case 0
            case 101
                set joshuto_cwd $(cat "$OUTPUT_FILE")
                cd "$joshuto_cwd" || echo "cd failed"
            case 102
            case '*'
                echo "Joshuto exit code: $exit_code"
        end

        rm -f "$OUTPUT_FILE"
    end
end
