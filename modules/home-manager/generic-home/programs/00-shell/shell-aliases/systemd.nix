{
  lib,
  pkgs,
  ...
}: let
  aliases = {
    sys = "systemctl";
    sysu = "systemctl --user";
  };
in {
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (
        lib.mapAttrsToList
        (
          key: value: ''abbr "${key}"="${value}"''
        )
        aliases
      )
    );
  };
}
