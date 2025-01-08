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
        # "laptop" # -- TODO
        "vm"
        "hypervisor"
      ];
      default = "vm";
    };
  };

  # options.${moduleName} = {
  #   type = mkOption {
  #     type = types.enum [
  #       "vm"
  #       "baremetal"
  #     ];
  #     default = "vm";
  #   };
  #   role = mkOption {
  #     type = types.enum [
  #       "desktop"
  #     ];
  #   };
  # };

  imports = [
    ./core
    ./common
    ./packages
    ./role
  ];
}
