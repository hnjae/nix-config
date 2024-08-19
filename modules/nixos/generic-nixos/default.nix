# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{lib, ...}: let
  moduleName = "generic-nixos";
  inherit (lib) types mkOption;
in {
  options.${moduleName} = {
    role = mkOption {
      type = types.enum [
        "desktop"
        "vm"
        "hypervisor"
      ];
      default = "vm";
    };
  };

  imports = [
    ./common
    ./packages
    ./role
  ];
}
