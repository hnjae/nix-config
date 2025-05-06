# https://github.com/cheat/cheat
{ pkgsUnstable, ... }:
{
  home.packages = with pkgsUnstable; [ cheat ];

  home.shellAliases = {
    ch = "cheat";
  };

  home.sessionVariables = {
    CHEAT_USE_FZF = "true";
  };
}
