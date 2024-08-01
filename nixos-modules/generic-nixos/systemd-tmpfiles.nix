{...}: {
  systemd.tmpfiles.rules = [
    # "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
    # "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    "d /mnt 755 root root"
  ];
}
