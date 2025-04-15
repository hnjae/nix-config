{
  lib,
  pkgs,
  ...
}:
let
  enableSecrueboot = true;
in
{
  boot = {
    lanzaboote = {
      enable = enableSecrueboot;
      pkiBundle = "/etc/secureboot";
      settings.console-mode = "keep"; # use vendor's firmware's default
    };
    loader = {
      # NOTE: lanzaboote replace the systemd-boot module
      systemd-boot = {
        enable = lib.mkForce (!enableSecrueboot);
        memtest86.enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    kernelParams = [
    ];
  };

  environment.systemPackages = [
    # for secure-boot
    pkgs.sbctl
  ];
}
