{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  imports = [
    ./night-light.nix
    ./window-decorations.nix
    ./splash-screen.nix
  ];

  programs.plasma.workspace = lib.mkIf genericHomeCfg.base24.enable {
    # run `plasma-apply-desktoptheme --list-themes`
    theme = "default";

    # run `plasma-apply-colorscheme --list-schemes`
    colorScheme =
      if genericHomeCfg.base24.darkMode
      then "BreezeDark"
      else "BreezeLight";

    # run `plasma-apply-cursortheme --list-themes`
    cursor.theme =
      if genericHomeCfg.base24.darkMode
      then "Breeze_Light"
      else "breeze_cursors";

    # run `plasma-apply-lookandfeel --list`
    lookAndFeel = "org.kde.breeze.desktop";

    iconTheme =
      if genericHomeCfg.base24.darkMode
      then "breeze-dark"
      else "breeze";
  };

  # to keep color appearance if not using base24
  # programs.plasma.resetFilesExclude = lib.lists.optional (! isBase24) "kdeglobals";

  # to keep color appearance
  programs.plasma.resetFilesExclude = ["kdeglobals"];
}
