# bash completion for autoaspm

_autoaspm() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--list --mode --run --verbose --help -l -m -v -h"

    case "${prev}" in
        --mode|-m)
            COMPREPLY=( $(compgen -W "l0s l1 l0sl1 disabled" -- ${cur}) )
            return 0
            ;;
        *)
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _autoaspm autoaspm
complete -F _autoaspm autoaspm.py
