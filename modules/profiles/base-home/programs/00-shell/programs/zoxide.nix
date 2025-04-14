{ config, ... }:
let
  posixFunction = ''
    s() {
      if [ "$#" -gt 0 ] && [ "$1" = "--" ]; then
        shift
      fi

      if [ -f "$*" ]; then
        __zoxide_z "$(dirname "$*")"
      else
        __zoxide_z "$@"
      fi
    }

    si() {
      __zoxide_zi "$@"
    }

    cd () {
      if [ "$#" -gt 0 ] && [ "$1" = "--" ]; then
        shift
      fi

      if [ "$#" -eq 0 ]; then
        return 0
      fi

      if [ "$#" -gt 1 ]; then
        echo "cd: too many arguments" >/dev/stderr
        return 1
      fi

      if [ -f "$*" ]; then
        __zoxide_z "$(dirname "$*")"
      elif [ -d "$*" ]; then
        __zoxide_z "$*"
      else
        echo "cd: $*: No such file or directory" >/dev/stderr
      fi
    }
  '';
in
{
  # cannot override z here
  programs.zoxide = {
    enable = true;
    # options = [ "--cmd cd" ];
    # options = [ "--nocmd" ];
  };
  programs.zsh.initExtra = posixFunction;
  programs.bash.initExtra = posixFunction;

  # programs.fish.functions.s = {
  #   body = ''
  #     __zoxide_z "$argv"
  #   '';
  # };
  # programs.fish.functions.si = {
  #   body = ''
  #     __zoxide_zi "$argv"
  #   '';
  # };

  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/zoxide";
      mode = "755";
      type = "dir";
    }
  ];

  home.sessionVariables = {
    # `_ZO_FZF_OPTS` 없으면 fzf 의 extended-search 가 작동하지 않는다. fzf 를 안사용하게 되나? <2025-04-11>
    _ZO_FZF_OPTS = builtins.concatStringsSep " " [
      config.home.sessionVariables.FZF_DEFAULT_OPTS
      "--scheme=path"
    ];
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
