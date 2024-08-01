{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  # provides org.freedesktop.upower interface
  services.upower.enable = mkOverride 999 isDesktop;
}
