_: pkgs: with pkgs; [
  # Basic features
  coreutils # cp/mv/chown ...
  psmisc # killall
  bc # bc
  iputils # ping
  sysstat # iostat

  # lsxxx
  lsof
  pciutils # lspci
  usbutils # lsusb

  # Requires root privilege
  hdparm # access physical device's firmware, ...
  dosfstools # mkfs.vfat
  powertop

  # Misc
  rsbkb # crc32
  beep # Advanced PC speaker beeper
]
