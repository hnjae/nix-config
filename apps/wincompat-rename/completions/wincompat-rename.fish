# fish completion for wincompat-rename

# Helper function to check if -- has been used
function __wincompat_rename_has_delimiter
    set -l tokens (commandline -opc)
    for token in $tokens
        if test "$token" = --
            return 0
        end
    end
    return 1
end

# Options (only complete if -- hasn't been used)
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -s r -l recursive -d 'Recursively traverse directories'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -s n -l dry-run -d 'Show changes without actually renaming'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -s H -l hidden -d 'Include hidden files (starting with .)'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -l process-dangerous-files -d 'Process dangerous paths'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -s h -l help -d 'Print help information'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -s V -l version -d 'Print version information'
complete -c wincompat-rename -n 'not __wincompat_rename_has_delimiter' -f -a -- -d 'Stop parsing options'

# Complete with files and directories (always available)
complete -c wincompat-rename -f -a '(__fish_complete_path)'
