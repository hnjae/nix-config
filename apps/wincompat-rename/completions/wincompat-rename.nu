# nushell completion for wincompat-rename

export extern "wincompat-rename" [
    ...paths: string                  # Files or directories to process
    --recursive(-r)                   # Recursively traverse directories
    --dry-run(-n)                     # Show changes without actually renaming
    --hidden(-H)                      # Include hidden files (starting with .)
    --process-dangerous-files         # Process dangerous paths
    --help(-h)                        # Print help information
    --version(-V)                     # Print version information
]
