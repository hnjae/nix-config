{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  inherit (lib.strings) optionalString;
in {
  programs.skim = {
    # NOTE: skim: fzf in rust
    enable = true;
    # package = pkgsUnstable.skim;
    package = pkgsUnstable.skim;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  home.packages = [
    (pkgs.runCommand "fzf" {} ''
      mkdir -p $out/bin
      ln -s "${config.programs.skim.package}/bin/sk" "$out/bin/fzf"
      ln -s "${config.programs.skim.package}/bin/sk-tmux" "$out/bin/fzf-tmux"
    '')
  ];

  programs.zsh.initExtra = with config.programs.skim; (optionalString (enable && (!enableZshIntegration)) ''
    if [[ $options[zle] = on ]]; then
      . ${package}/share/skim/completion.zsh
      . ${package}/share/skim/key-bindings.zsh
    fi
  '');

  home.sessionVariables = let
    skim_command = [
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
      #
      ''--exclude \"node_modules\"''
      ''--exclude \".mypy_cache\"''
      ''--exclude \".ruff_cache\"''
      ''--exclude \".__pycache__\"''
    ];
  in {
    SKIM_ALT_C_COMMAND =
      builtins.concatStringsSep " "
      (skim_command ++ ["--type d" "--one-file-system" "." "2>/dev/null"]);
    SKIM_CTRL_T_COMMAND = builtins.concatStringsSep " " (skim_command
      ++ [
        ''--exclude \".DS_Store\"''
        ''--exclude \"*.pyc\"''
        ''--exclude \"*.swp\"''
        ''--exclude \"*.thumbsnail\"''
        "--type f --type d --type l"
        "--one-file-system"
        "."
        "2>/dev/null"
      ]);
  };
}
