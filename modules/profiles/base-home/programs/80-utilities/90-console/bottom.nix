{
  pkgsUnstable,
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  isLinuxDesktop = pkgs.stdenv.isLinux && baseHomeCfg.isDesktop;
  appId = "bottom";

  icon = "${pkgs.pantheon.elementary-icon-theme}/share/icons/elementary/apps/128/utilities-system-monitor.svg";

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
  home.packages = lib.flatten [
    pkgsUnstable.bottom
    (lib.lists.optional isLinuxDesktop iconPkg)
  ];

  xdg.dataFile."applications/${appId}.desktop" = lib.mkIf (isLinuxDesktop) {
    text = ''
      [Desktop Entry]
      Categories=System;Monitor
      Comment=with custom desktop entry
      Exec=${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title bottom -e btm %F
      Icon=${icon}
      Keywords=system;process;task
      Name=Bottom (btm)
      StartupNotify=false
      Terminal=false
      Type=Application
      Version=1.4
    '';
  };
}
