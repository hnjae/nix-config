# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.base-nixos = {
    hostType = mkOption {
      type = types.enum [
        "vm"
        "baremetal"
      ];
      default = "baremetal";
      description = "The hardware type of the machine";
    };
    role = mkOption {
      type = types.enum [
        "desktop"
        "none"
      ];
      default = "none";
      description = "System role/purpose";
    };
  };

  imports = [
    ./core
    ./common
    ./packages
    ./role
  ];
}
