{
  pkgs,
  lib,
  pkgsUnstable,
  config,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  home.packages = [pkgsUnstable.libqalculate];

  # services.flatpak.packages = lib.lists.optional (baseHomeCfg.isDesktop) "io.github.Qalculate.qalculate-qt";

  xdg.desktopEntries.qalc = lib.mkIf (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) {
    name = "Qalculate";
    comment = "w. custom .desktop entry";
    # exec = "footclient --app-id=qalc --title=Qalculate -e qalc";
    exec = "${pkgs.alacritty}/bin/alacritty --class qalc,qalc --title Qalculate -e qalc %F";
    terminal = false;
    # icon = "accessories-calculator";
    icon = "${pkgs.colloid-icon-theme}/share/icons/Colloid/apps/scalable/io.github.Qalculate.svg";
    type = "Application";
    startupNotify = false;
    categories = ["Utility" "Calculator"];
    settings = {
      Keywords = builtins.concatStringsSep ";" [
        "calculation"
        "arithmetic"
        "scientific"
        "financial"
      ];
    };
  };
}
