{
  pkgsUnstable,
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  icon = "${pkgs.pantheon.elementary-icon-theme}/share/icons/elementary/apps/128/utilities-system-monitor.svg";
  appId = "btm";

  iconPkg = pkgs.runCommandLocal appId { } ''
    mkdir -p "$out/share/icons/hicolor/scalable/apps/"

    cp --reflink=auto \
      "${icon}" \
      "$out/share/icons/hicolor/scalable/apps/${appId}.svg"

    paths=(
      "$out/share/icons/hicolor/512x512/apps/"
      "$out/share/icons/hicolor/256x256/apps/"
      "$out/share/icons/hicolor/128x128/apps/"
      "$out/share/icons/hicolor/64x64/apps/"
      "$out/share/icons/hicolor/48x48/apps/"
      "$out/share/icons/hicolor/32x32/apps/"
      "$out/share/icons/hicolor/16x16/apps/"
    )
    for path in "''${paths[@]}"; do
      mkdir -p "''$path"
      ln -s \
        "$out/share/icons/hicolor/scalable/apps/${appId}.svg" \
        "''${path}/${appId}.svg"
    done
  '';
in
{
  programs.bottom = {
    enable = true;
    package = pkgsUnstable.bottom;
    # settings = { };
  };

  xdg.desktopEntries.${appId} = lib.mkIf (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) {
    name = "Bottom (btm)";
    comment = "w. custom .desktop entry";
    exec = "${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title bottom -e btm %F";
    # exec = "footclient --app-id=btm --title=bottom -e btm";
    terminal = false;
    inherit icon;
    type = "Application";
    startupNotify = false;
    categories = [
      "System"
      "Monitor"
    ];
    settings = {
      Keywords = builtins.concatStringsSep ";" [
        "system"
        "process"
        "task"
      ];
    };
  };

  home.packages = lib.mkIf (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) [
    iconPkg
  ];
}
