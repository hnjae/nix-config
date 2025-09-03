{
  lib,
  pkgs,
  ...
}:
let
  enableSecrueboot = false;
in
{
  boot = {
    lanzaboote = {
      enable = enableSecrueboot;
      # pkiBundle = "/persist/etc/secureboot";
      pkiBundle = "/var/lib/sbctl";
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
      # https://forum.proxmox.com/threads/realtek-usb-2-5-gbe-random-usb-disconnect.138253/

      # > Bus 002 Device 002: ID 0bda:8156 Realtek Semiconductor Corp. USB 10/100/1G/2.5G LAN
      "usbcore.autosuspend=-1"
      "usbcore.quirks=0bda:8156:k"

      "zswap.enabled=1"
      # "zswap.compressor=zstd"
    ];
  };

  environment.systemPackages = [
    # for secure-boot
    pkgs.sbctl
  ];
}
