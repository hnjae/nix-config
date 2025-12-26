# fish completion for autoaspm

complete -c autoaspm -s l -l list -d 'List ASPM-capable devices and their supported modes'
complete -c autoaspm -s m -l mode -d 'Default ASPM mode for all devices' -xa 'l0s l1 l0sl1 disabled'
complete -c autoaspm -l device-mode -d 'Set ASPM mode for specific device (vendor:device=mode)' -x
complete -c autoaspm -l skip -d 'Skip patching for specific device (vendor:device)' -x
complete -c autoaspm -l run -d 'Actually apply patches (default is dry-run)'
complete -c autoaspm -s v -l verbose -d 'Show detailed device information'
complete -c autoaspm -s h -l help -d 'Show help message and exit'
