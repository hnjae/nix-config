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

  # NOTE: these firmware will be loaded if kernel requested <2023-10-03>
  hardware.enableAllFirmware = pkgs.config.allowUnfree;
  hardware.enableRedistributableFirmware = pkgs.config.allowUnfree;
}
