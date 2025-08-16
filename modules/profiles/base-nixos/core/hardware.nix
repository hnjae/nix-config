{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.base-nixos;
in
{
  # https://www.kernel.org/category/releases.html
  # https://github.com/openzfs/zfs/releases/
  # nix repl -f '<nixpkgs-stable>'; type pkgs.linuxPackages_ to find kernel version
  # NOTE: Updated: NixOS 25.05
  boot.kernelPackages = lib.mkOverride 999 (
    if cfg.role != "desktop" then pkgs.linuxPackages_6_12_hardened else pkgs.linuxPackages_6_12
  );

  # NOTE: these firmware will be loaded if kernel requested <2023-10-03>
  hardware.enableAllFirmware = pkgs.config.allowUnfree;
  hardware.enableRedistributableFirmware = pkgs.config.allowUnfree;
}
