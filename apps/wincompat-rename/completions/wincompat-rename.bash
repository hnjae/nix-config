# bash completion for wincompat-rename

_wincompat_rename_completions() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="-r --recursive -n --dry-run -H --hidden --process-dangerous-files -h --help -V --version"

  case "$cur" in
  -*)
    COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
    return 0
    ;;
  *)
    # Complete with files and directories
    COMPREPLY=("$(compgen -f -- "$cur")")
    return 0
    ;;
  esac
}

complete -F _wincompat_rename_completions wincompat-rename
