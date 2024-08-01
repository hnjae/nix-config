# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{lib, ...}: let
  moduleName = "generic-nixos";
in {
  options.${moduleName} = {
    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  imports = [
    ./hardware.nix
    ./console.nix
    ./env.nix
    ./packages
    ./zram.nix
    ./sysctl.nix
    ./locale.nix
    ./documentation.nix
    ./davfs2.nix
    ./systemd.nix
    ./services
    ./home-manager.nix
    ./nix.nix
    ./time.nix
    ./network.nix
    ./users.nix
    ./keyboard.nix
    ./systemd-tmpfiles.nix
    ./pam.nix
  ];
}
