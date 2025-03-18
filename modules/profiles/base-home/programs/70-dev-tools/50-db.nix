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
  config = lib.mkIf baseHomeCfg.isDev {
    home.packages = with pkgs; [
      mongosh
      sqlite
    ];

    services.flatpak.packages = [
      # db tool
      "io.dbeaver.DBeaverCommunity" # Apache-2.0
      "io.beekeeperstudio.Studio" # GPL3
      "org.pgadmin.pgadmin4"

      # sql client, uses end-of-life dependency
      "com.github.alecaddd.sequeler"
      "com.mongodb.Compass" # Proprietary
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
