{
  config,
  lib,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    services.flatpak.packages = ["com.usebottles.bottles"];

    services.flatpak.overrides."com.usebottles.bottles" = {
      Context = {filesystems = ["home"];};
    };
  };
}
