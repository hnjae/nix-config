{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  # org.freedesktop.resolve1
  services.resolved.enable = mkOverride 999 isDesktop;
}
