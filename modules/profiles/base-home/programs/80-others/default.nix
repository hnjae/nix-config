{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./50-llm.nix
  ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      (lib.lists.optionals baseHomeCfg.isHome [
        "net.ankiweb.Anki"
      ])
    ];
  };
}
