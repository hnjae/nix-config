{
  pkgs,
  pkgsUnstable,
  ...
}: {
  home.packages = with pkgsUnstable; [cheat];

  home.shellAliases = {ch = "cheat";};
}
