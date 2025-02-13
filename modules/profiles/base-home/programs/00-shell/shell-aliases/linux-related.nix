{
  lib,
  pkgs,
  ...
}:
let
  aliases = {
    fl = "flatpak --user";
    flr = "flatpak --user run";
    flx = "flatpak --user run";
    fls = "flatpak --user search";
    fli = "flatpak --user install";
    flu = "flatpak --user update";
    flh = "flatpak --help";
    flps = "flatpak ps";
    flK = "flatpak kill";
  };
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') aliases)
    );
  };
}
