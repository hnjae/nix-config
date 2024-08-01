{
  pkgs,
  lib,
  pkgsUnstable,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  home.packages = [pkgsUnstable.libqalculate];

  # services.flatpak.packages = lib.lists.optional (genericHomeCfg.isDesktop) "io.github.Qalculate.qalculate-qt";

  xdg.desktopEntries.qalc = lib.mkIf (pkgs.stdenv.isLinux && genericHomeCfg.isDesktop) {
    name = "Qalculate";
    comment = "w. custom .desktop entry";
    exec = "footclient --app-id=qalc --title=Qalculate -e qalc";
    terminal = false;
    icon = "accessories-calculator";
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
