# fish completion for wincompat-rename

complete -c wincompat-rename -s r -l recursive -d 'Recursively traverse directories'
complete -c wincompat-rename -s n -l dry-run -d 'Show changes without actually renaming'
complete -c wincompat-rename -s H -l hidden -d 'Include hidden files (starting with .)'
complete -c wincompat-rename -l process-dangerous-files -d 'Process dangerous paths'
complete -c wincompat-rename -s h -l help -d 'Print help information'
complete -c wincompat-rename -s V -l version -d 'Print version information'

# Complete with files and directories
complete -c wincompat-rename -a '(__fish_complete_path)'
