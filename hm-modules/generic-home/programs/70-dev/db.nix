{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
    home.packages = with pkgs; [mongosh];

    services.flatpak.packages = lib.mkIf genericHomeCfg.isDesktop [
      "io.dbeaver.DBeaverCommunity" # db tool
    ];
  };
}
