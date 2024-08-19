{
  config,
  lib,
  pkgsUnstable,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  imports = [
    ./zathura
  ];

  config = lib.mkIf genericHomeCfg.installDevPackages {
    services.flatpak.packages = builtins.concatLists [
      (lib.lists.optionals genericHomeCfg.installTestApps [
        "com.github.jeromerobert.pdfarranger"
        "com.github.ahrm.sioyek" # pdfviewer
      ])
    ];

    home.packages = builtins.concatLists [
      (
        lib.lists.optionals (genericHomeCfg.installDevPackages) (
          with pkgsUnstable; [ocrmypdf img2pdf]
        )
      )
      (
        lib.lists.optionals (
          genericHomeCfg.installTestApps && pkgs.stdenv.isLinux
        ) []
      )
    ];
  };
}
