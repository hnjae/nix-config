# bash completion for autoaspm

_autoaspm() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts="--list --mode --device-mode --skip --run --verbose --help -l -m -v -h"

  case "$prev" in
  --mode | -m)
    mapfile -t COMPREPLY < <(compgen -W "l0s l1 l0sl1 disabled" -- "$cur")
    return 0
    ;;
  --device-mode)
    # Suggest mode suffix after vendor:device=
    if [[ $cur == *=* ]]; then
      local prefix="${cur%=*}="
      local suffix="${cur##*=}"
      mapfile -t modes < <(compgen -W "l0s l1 l0sl1 disabled" -- "$suffix")
      COMPREPLY=("${modes[@]/#/${prefix}}")
    else
      # Suggest vendor:device= format
      mapfile -t COMPREPLY < <(compgen -W "VENDOR:DEVICE=" -- "$cur")
    fi
    return 0
    ;;
  --skip)
    # Suggest vendor:device format
    mapfile -t COMPREPLY < <(compgen -W "VENDOR:DEVICE" -- "$cur")
    return 0
    ;;
  *) ;;
  esac

  mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
  return 0
}

complete -F _autoaspm autoaspm
complete -F _autoaspm autoaspm.py
