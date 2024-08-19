{
  lib,
  config,
  ...
}: {
  # services.flatpak-update.enable = mkOverride 999 true;
  # services.flatpak-uninstall-unused.enable = mkOverride 999 true;

  services.flatpak.enable = config.generic-nixos.role == "desktop";

  # https://bbs.archlinux.org/viewtopic.php?id=261143
  fonts.fontDir.enable = lib.mkOverride 999 config.services.flatpak.enable; #: Whether to create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts.

  # NOTE: and symlink of following to use fonts/icon in flatpak apps
  systemd.tmpfiles.rules = lib.lists.optionals config.services.flatpak.enable [
    "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
    "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
  ];
  # "L /usr/share/mime - - - - /run/current-system/sw/share/mime"
}
