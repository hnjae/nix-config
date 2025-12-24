# nushell completion for autoaspm

export extern autoaspm [
    --list(-l)              # List ASPM-capable devices and their supported modes
    --mode(-m): string@"nu-complete autoaspm modes"  # ASPM mode to enable
    --run                   # Actually apply patches (default is dry-run)
    --verbose(-v)           # Show detailed device information
    --help(-h)              # Show help message and exit
]

def "nu-complete autoaspm modes" [] {
    ["l0s" "l1" "l0sl1" "disabled"]
}
