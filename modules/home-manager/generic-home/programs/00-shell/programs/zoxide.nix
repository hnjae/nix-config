{config, ...}: let
  posixFunction = ''
    s() {
      # if [ -n "$1" ] && [ -f "$1" ]; then
      #   path="$(dirname "$1")"
      #   __zoxide_z "$path"
      # else
      #   __zoxide_z "$@"
      # fi
      __zoxide_z "$@"
    }

    si() {
      __zoxide_zi "$@"
    }
  '';
in {
  # cannot override z here
  programs.zoxide.enable = true;
  programs.zsh.initExtra = posixFunction;
  programs.bash.initExtra = posixFunction;
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

  stateful.nocowNodes = [
    {
      path = "${config.xdg.dataHome}/zoxide";
      mode = "755";
      type = "dir";
    }
  ];
}
