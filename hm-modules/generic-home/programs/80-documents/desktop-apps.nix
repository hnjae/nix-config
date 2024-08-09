{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      [
        "com.calibre_ebook.calibre"
      ]
      (optionals genericHomeCfg.installTestApps [
        "com.jgraph.drawio.desktop" # apache2

        "com.github.jeromerobert.pdfarranger"

        # "com.github.fabiocolacio.marker" # markdown editor
        # "com.toolstack.Folio" # markdown notebooks

        "org.gaphor.Gaphor" # UML modeling, apache 2
        "se.sjoerd.Graphs" # manipulate data and plot, gpl3

        "io.github.finefindus.Hieroglyphic" # find latex symbols
        "fyi.zoey.TeX-Match" # find latex symbols
      ])
    ];

    home.packages = builtins.concatLists [
      (optionals (genericHomeCfg.installTestApps && pkgs.stdenv.isLinux) [
        pkgs.sioyek # pdfviewer
      ])
    ];
  };
}
