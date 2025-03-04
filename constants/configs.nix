{
  resticExcludes = [
    # Linux
    ".directory" # KDE
    ".Trash-*"
    ".nfs*"
    ".fuse_hidden*"
    ".snapshots" # snapper

    # macOS
    ".DS_Store"
    ''._\*'' # thumbnails
    ".localized"

    # MS Windows
    "Thumbs.db"
    "Desktop.ini"
    "desktop.ini"
    "$RECYCLE.BIN"

    # Android
    ".temp"
    ".thumbnails"

    # Misc
    ".cache"

    # temporary files
    "*.parts"
    ".direnv" # nix-flake

    # vscode
    ".vscode-server"

    # vim
    "tags"
    "*.swp"
    "*~"

    # shell related
    "fish_variables"
    "*.zcompdump"
    ".zsh_history"
    ".bash_history"

    # python related
    ".venv"
    "__pycache__"
    ".pyc"

    # python tools
    ".ropeproject"
    ".mypy_cache"
    ".ruff_cache"
    ".pyre"

    # nodejs related
    "node_modules"

    # program build results (python, nodejs)
    "dist"

    # logseq
    "logseq/.recycle"
    "logseq/bak"
  ];
}
