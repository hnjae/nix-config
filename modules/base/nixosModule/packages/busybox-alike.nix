{ pkgs, ... }:
{
  # Set of default packages that aren't strictly necessary for a running system
  environment.defaultPackages = with pkgs; [
    # basic features
    coreutils-full # cp/mv/chown ...
    bc # bc
    iputils # ping
    psmisc # killall
    dosfstools # mkfs.vfat
    lsof
    beep
    sysstat # iostat

    pciutils # lspci
    usbutils # lsusb

    wget

    rsbkb # crc32

    # access physical device's firmware, ...
    hdparm
  ];
}
