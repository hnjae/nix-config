# https://github.com/cheat/cheat
{ pkgsUnstable, lib, ... }:

let
  aliases = {
    ch = "cheat";
    che = "cheat -e";
  };
in
{
  home.packages = with pkgsUnstable; [ cheat ];

  home.shellAliases = aliases;
  xdg.configFile."zsh-abbr/user-abbreviations".text = (
    lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') aliases)
  );

  home.sessionVariables = {
    CHEAT_USE_FZF = "true";
  };
}
