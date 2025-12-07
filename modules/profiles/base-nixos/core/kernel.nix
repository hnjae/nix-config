/*
  Updated: NixOS 25.05

  NOTE:
    - https://www.kernel.org/category/releases.html
    - https://github.com/openzfs/zfs/releases/

  Run following to find kernel packages in NixOS:

  ```console
  nix repl -f '<nixpkgs>'
  nix-repl> pkgs.linuxPackages_
  ```
*/
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
  boot = {
    kernelPackages = lib.mkOverride 999 (
      if cfg.role != "desktop" then pkgs.linuxPackages_6_12_hardened else pkgs.linuxPackages_6_12
    );

    kernelModules = [ "wireguard" ];
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0; # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
      "vm.dirty_writeback_centisecs" = 1500; # follow powertop recommendation 2025-11-23
    };
  };
}
