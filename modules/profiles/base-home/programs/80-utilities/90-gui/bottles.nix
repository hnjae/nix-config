{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && isLinux) {
    services.flatpak.packages = [ "com.usebottles.bottles" ];

    services.flatpak.overrides."com.usebottles.bottles" = {
      Context = {
        filesystems = [ "home" ];
      };
    };
  };
}
