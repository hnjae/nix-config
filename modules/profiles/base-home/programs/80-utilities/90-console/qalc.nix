{
  pkgs,
  pkgsUnstable,
  ...
}:
let
  appId = "qalculate";
  icon = "${pkgs.cosmic-icons}/share/icons/Cosmic/scalable/apps/accessories-calculator.svg";
in
{
  home.packages = [
    pkgsUnstable.libqalculate
    (pkgs.runCommandLocal appId { } ''
      mkdir -p "$out/share/icons/hicolor/scalable/apps/"

      cp --reflink=auto \
        "${icon}" \
        "$out/share/icons/hicolor/scalable/apps/${appId}.svg"
    '')

    (pkgs.makeDesktopItem {
      name = appId;
      desktopName = "Qalculate";
      categories = [
        "Utility"
        "Calculator"
      ];
      keywords = [
        "calculation"
        "arithmetic"
        "scientific"
        "financial"
      ];
      exec = "${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title Qalculate -e qalc %F";
      terminal = false;
      startupNotify = false;
      type = "Application";
      # icon = "accessories-calculator";
      icon = appId;

      # NOTE: icon=<full-path-to-icon> 식으로 지정하면, Gnome 에서는 잘 처리하나, KDE 에서는 처리하지 못함 <NixOS 25.05; KDE 6.3>.
    })
  ];
}
