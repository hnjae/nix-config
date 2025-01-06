{
  config,
  lib,
  pkgs,
  ...
}: let
  isDesktop = config.generic-nixos.role == "desktop";
  inherit (lib) mkOverride;
in {
  boot.kernelPackages = mkOverride 999 (
    if isDesktop
    then pkgs.linuxPackages_zen
    else pkgs.linuxPackages_6_6_hardened
  );

  # NOTE: these firmware will be loaded if kernel requested <2023-10-03>
  hardware.enableAllFirmware = pkgs.config.allowUnfree;
  hardware.enableRedistributableFirmware = pkgs.config.allowUnfree;
}
