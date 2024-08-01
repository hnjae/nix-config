{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  # printing
  services.printing.enable = mkOverride 999 isDesktop;
}
