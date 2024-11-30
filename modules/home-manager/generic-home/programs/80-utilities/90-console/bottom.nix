{
  pkgsUnstable,
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  programs.bottom = {
    enable = true;
    package = pkgsUnstable.bottom;
    # settings = { };
  };

  xdg.desktopEntries.bottom = lib.mkIf (pkgs.stdenv.isLinux && genericHomeCfg.isDesktop) {
    name = "Bottom (btm)";
    comment = "w. custom .desktop entry";
    exec = "${pkgs.alacritty}/bin/alacritty --class btm,btm --title bottom -e btm %F";
    # exec = "footclient --app-id=btm --title=bottom -e btm";
    terminal = false;
    icon = "utilities-system-monitor";
    type = "Application";
    startupNotify = false;
    categories = ["System" "Monitor"];
    settings = {
      Keywords = builtins.concatStringsSep ";" ["system" "process" "task"];
    };
  };
}
