{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgs; [mongosh sqlite];

    services.flatpak.packages = lib.mkIf genericHomeCfg.isDesktop [
      "io.dbeaver.DBeaverCommunity" # db tool
      # "com.github.alecaddd.sequeler" # sql client, uses end-of-life dependency
    ];
  };
}
