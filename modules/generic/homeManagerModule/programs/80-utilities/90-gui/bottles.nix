{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    services.flatpak.packages = ["com.usebottles.bottles"];

    services.flatpak.overrides."com.usebottles.bottles" = {
      Context = {filesystems = ["home"];};
    };
  };
}
