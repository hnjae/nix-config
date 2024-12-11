{
  config,
  lib,
  ...
}: let
  posixFunction = ''
    s() {
      # if [ -n "$1" ] && [ -f "$1" ]; then
      #   path="$(dirname "$1")"
      #   __zoxide_z "$path"
      # else
      #   __zoxide_z "$@"
      # fi
      if [ -f "$@" ]; then
        __zoxide_z "$(dirname "$@")"
      else
        __zoxide_z "$@"
      fi
    }

    si() {
      __zoxide_zi "$@"
    }
  '';
in {
  # cannot override z here
  programs.zoxide = {
    enable = true;
    options = ["--cmd s"];
  };
  # programs.zsh.initExtra = posixFunction;
  # programs.bash.initExtra = posixFunction;
  programs.fish.functions.s = {
    body = ''
      __zoxide_z "$argv"
    '';
  };
  programs.fish.functions.si = {
    body = ''
      __zoxide_zi "$argv"
    '';
  };

  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/zoxide";
      mode = "755";
      type = "dir";
    }
  ];

  home.sessionVariables = {
    # _ZO_FZF_OPTS = builtins.concatStringsSep " " [
    #   ];
    _ZO_EXCLUDE_DIRS = builtins.concatStringsSep ":" [
      "$HOME"
      "/nix/*"
      "/mnt/*"
      "/proc/*"
      "*/.git"
      "*/.cache"
      "*/.direnv"
    ];
  };
}
