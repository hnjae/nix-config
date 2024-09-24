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
        # "com.github.fabiocolacio.marker" # markdown editor
        # "com.toolstack.Folio" # markdown notebooks

        "se.sjoerd.Graphs" # manipulate data and plot, gpl3

        "org.onlyoffice.desktopeditors" # agpl-3.0
      ])
    ];
  };
}
