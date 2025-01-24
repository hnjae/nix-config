{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = with pkgs; [
      mongosh
      sqlite
    ];

    services.flatpak.packages = [
      "io.dbeaver.DBeaverCommunity" # db tool
      # sql client, uses end-of-life dependency
      "com.github.alecaddd.sequeler"
    ];

    services.flatpak.overrides = {
      "com.github.alecaddd.sequeler" = {
        Context = {
          shared = [ "!network" ];
        };
      };
    };
  };
}
