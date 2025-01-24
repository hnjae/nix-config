{
  lib,
  pkgs,
  ...
}: {
  boot.kernelPackages = lib.mkOverride 999 pkgs.linuxPackages_6_6_hardened;

  # NOTE: these firmware will be loaded if kernel requested <2023-10-03>
  hardware.enableAllFirmware = pkgs.config.allowUnfree;
  hardware.enableRedistributableFirmware = pkgs.config.allowUnfree;
}
