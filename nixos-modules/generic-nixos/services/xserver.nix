{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  services.xserver.enable = mkOverride 999 isDesktop;
}
