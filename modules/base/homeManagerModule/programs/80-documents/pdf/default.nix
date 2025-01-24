{
  config,
  lib,
  pkgsUnstable,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  imports = [
    ./zathura
  ];

  config = {
    services.flatpak.packages = builtins.concatLists [
      (lib.lists.optionals baseHomeCfg.installTestApps [
        "com.github.jeromerobert.pdfarranger"
        "com.github.ahrm.sioyek" # pdfviewer
        "org.gnome.Papers"
        "org.gnome.Evince"
      ])
    ];

    home.packages = builtins.concatLists [
      (
        lib.lists.optionals (baseHomeCfg.installDevPackages) (
          with pkgsUnstable; [ocrmypdf img2pdf]
        )
      )
      (
        lib.lists.optionals (
          baseHomeCfg.installTestApps && pkgs.stdenv.isLinux
        ) []
      )
    ];
  };
}
