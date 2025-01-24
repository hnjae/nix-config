{
  config,
  lib,
  pkgsUnstable,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./zathura
  ];

  config = {
    services.flatpak.packages = builtins.concatLists [
      [
        "com.github.jeromerobert.pdfarranger"
        "com.github.ahrm.sioyek" # pdfviewer
        "org.gnome.Papers"
      ]
    ];

    home.packages = builtins.concatLists [
      (lib.lists.optionals (baseHomeCfg.isDev) (
        with pkgsUnstable;
        [
          ocrmypdf
          img2pdf
        ]
      ))
    ];
  };
}
