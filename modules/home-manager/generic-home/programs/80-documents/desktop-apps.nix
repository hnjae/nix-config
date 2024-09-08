{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      (optionals genericHomeCfg.installTestApps [
        "com.jgraph.drawio.desktop" # apache2

        # "com.github.fabiocolacio.marker" # markdown editor
        # "com.toolstack.Folio" # markdown notebooks

        "org.gaphor.Gaphor" # UML modeling, apache 2
        "se.sjoerd.Graphs" # manipulate data and plot, gpl3

        "org.onlyoffice.desktopeditors" # agpl-3.0
      ])
    ];
  };
}
