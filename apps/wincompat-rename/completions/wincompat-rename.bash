# bash completion for wincompat-rename

_wincompat_rename_completions() {
  local cur opts i
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="-r --recursive -n --dry-run -H --hidden --process-dangerous-files -h --help -V --version --"

  # Check if -- has appeared in previous arguments
  local parsing_options=true
  for ((i = 1; i < COMP_CWORD; i++)); do
    if [[ ${COMP_WORDS[i]} == "--" ]]; then
      parsing_options=false
      break
    fi
  done

  if [[ $parsing_options == true ]]; then
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
  else
    # After --, only complete with files and directories
    COMPREPLY=("$(compgen -f -- "$cur")")
    return 0
  fi
}

complete -F _wincompat_rename_completions wincompat-rename
