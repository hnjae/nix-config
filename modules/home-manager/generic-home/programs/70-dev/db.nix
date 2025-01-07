{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
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
        Context = {shared = ["!network"];};
      };
    };
  };
}
