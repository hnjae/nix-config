{
  pkgs,
  lib,
  ...
}:
let
  rsyncArgs = [
    # "ionice"
    # "-c"
    # "idle"
    "rsync"
    "--info=progress2"
    "-h"
    "-s" # -s: --secluded-args, avoids letting the remote shell modify filenames
    "-aHAXWE"
    "--numeric-ids"
    "--exclude-from=${rsync-exclude}"
  ];
  rsyncSshArgs = [
    "-z"
    "--zc=zstd"
    "--zl=3"
    # "--skip-compress=mp3,mp4,avi,mov,flac,zip,gz,tar"
    "-e"
    ''"ssh -T -c aes128-gcm@openssh.com -o Compression=no -x"''
  ];

  # *.log
  rsync-exclude = pkgs.writeText "rsync-exclude" ''
    .Trash-*
    .snapshots
    .jekyll-cache
    *.tmp
    *.swp
    Thumbs.db
    .thumbnails
    .directory
    .DS_Store
    .cache
    .ropeproject
    __pycache__
    .mypy_cache
    .ruff_cache
    .pyc
    fish_variables
    *.zcompdump
    .zsh_history
    .direnv
    node_modules
    npm-cache
    .vscode-server
    .stversions
  '';

  inherit (builtins) mapAttrs concatStringsSep concatLists;
in
{
  home.shellAliases = mapAttrs (_: args: concatStringsSep " " args) {
    rcp = rsyncArgs;
    rmv = concatLists [
      rsyncArgs
      [ "--remove-source-files" ]
    ];
    rcp-paranoid = concatLists [
      rsyncArgs
      [
        "--checksum"
        "--cc=xxh3" # (https://github.com/Cyan4973/xxHash)
      ]
    ];

    rcp-remote = concatLists [
      rsyncArgs
      rsyncSshArgs
    ];
    rmv-remote = concatLists [
      rsyncArgs
      [ "--remove-source-files" ]
      rsyncSshArgs
    ];

    rcp-sync = concatLists [
      (lib.lists.remove "--exclude-from=${rsync-exclude}" rsyncArgs)
      [
        # "--checksum"
        # "--cc=xxh3" # (https://github.com/Cyan4973/xxHash)
        # "--delete-delay"
        "--fuzzy"
        "--delete-after"
      ]
    ];

    rcp-mtp = [
      "rsync"
      "--info=progress2"
      "-h"
      "-rt" # recursive, time
      "-W" # whole files
      "-s"
      "--safe-links" # ignore symlink that points outside of tree
      "--checksum"
      "--cc=xxh3"
      "--omit-dir-times"
      "--no-perms"
      "--inplace" # inplace file. no copy file then replace it.
      "--exclude-from=${rsync-exclude}"
    ];
  };
}
