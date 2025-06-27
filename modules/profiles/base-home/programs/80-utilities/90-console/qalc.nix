{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  home.packages = [
    pkgsUnstable.libqalculate
    (pkgs.makeDesktopItem {
      desktopName = "Qalculate";
      name = "qalcuate";
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
      exec = "${pkgs.alacritty}/bin/alacritty --class qalc,qalc --title Qalculate -e qalc %F";
      terminal = false;
      startupNotify = false;
      type = "Application";
      # icon = "accessories-calculator";
      icon = "${pkgs.cosmic-icons}/share/icons/Cosmic/scalable/apps/accessories-calculator.svg";
      # icon = "${pkgs.colloid-icon-theme}/share/icons/Colloid/apps/scalable/io.github.Qalculate.svg";
      # /nix/store/wyjgkavzidsxa2v1klwald80120s2z10-breeze-icons-6.14.0/share/icons/breeze/apps/48/accessories-calculator.svg

    })
  ];
}
