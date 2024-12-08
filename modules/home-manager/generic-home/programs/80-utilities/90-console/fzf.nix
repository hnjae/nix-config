{pkgsUnstable, ...}: {
  programs.fzf = {
    enable = true;
    package = pkgsUnstable.fzf;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = let
    fzf_command = [
      "command fd"
      "-H"
      "-L"
      "--min-depth 1"
      "--ignore-vcs"
      #
      ''--exclude \".cache\"''
      ''--exclude \".direnv\"''
      # git
      ''--exclude \".git\"''
      ''--exclude \".github\"''
      ''--exclude \".gitlab\"''
      # editor
      ''--exclude \".idea\"''
      ''--exclude \".vscode\"''
      ''--exclude \".vscode-server\"''
      # nodejs
      ''--exclude \"node_modules\"''
      # python
      ''--exclude \".mypy_cache\"''
      ''--exclude \".ruff_cache\"''
      ''--exclude \".__pycache__\"''
    ];
  in {
    FZF_DEFAULT_OPTS = builtins.concatStringsSep " " [
      "--color=16"
    ];
    FZF_ALT_C_COMMAND =
      builtins.concatStringsSep " "
      (fzf_command
        ++ [
          "--color=16"
          "--type d"
          "."
          "2>/dev/null"
        ]);

    FZF_CTRL_R_OPTS = builtins.concatStringsSep " " [
      "--color=16"
    ];

    FZF_CTRL_T_COMMAND = builtins.concatStringsSep " " (fzf_command
      ++ [
        ''--exclude \".DS_Store\"''
        ''--exclude \"*.pyc\"''
        ''--exclude \"*.swp\"''
        ''--exclude \"*.thumbsnail\"''
        "--type f --type d --type l"
        "--one-file-system"
        "--color=16"
        "."
        "2>/dev/null"
      ]);
  };
}
