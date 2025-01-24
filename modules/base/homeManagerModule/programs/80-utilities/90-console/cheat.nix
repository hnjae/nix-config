# https://github.com/cheat/cheat
{ pkgsUnstable, ... }:
{
  home.packages = with pkgsUnstable; [ cheat ];

  home.shellAliases = {
    ch = "cheat";
  };
}
