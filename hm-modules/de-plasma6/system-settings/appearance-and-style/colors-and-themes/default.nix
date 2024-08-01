{
  config,
  lib,
  ...
}: let
  # isBase24 = config.plasma6.base24.enable;
  base24Cfg = config.base24;

  cursorTheme =
    if base24Cfg.variant == "light"
    then "Breeze"
    else "BreezeLight";

  colorScheme =
    if base24Cfg.variant == "light"
    then "BreezeLight"
    else "Breeze";
in {
  imports = [./night-light.nix ./window-decorations.nix ./splash-screen.nix];

  programs.plasma.workspace = {
    theme = "default";
    lookAndFeel = "org.kde.breeze.desktop";
    inherit colorScheme;
    cursor.theme = cursorTheme;
    # iconTheme = "Breeze";
  };

  # to keep color appearance if not using base24
  # programs.plasma.resetFilesExclude = lib.lists.optional (! isBase24) "kdeglobals";

  # to keep color appearance
  programs.plasma.resetFilesExclude = ["kdeglobals"];
}
