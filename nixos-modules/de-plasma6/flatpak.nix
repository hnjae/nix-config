# import this unit if xserver.enable
{lib, ...}: let
  inherit (lib) mkOverride;
in {
  imports = [
  ];

  # services.flatpak-update.enable = mkOverride 999 true;
  # services.flatpak-uninstall-unused.enable = mkOverride 999 true;

  services.flatpak.enable = mkOverride 999 true;

  # https://bbs.archlinux.org/viewtopic.php?id=261143
  fonts.fontDir.enable = true; #: Whether to create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts.
  # NOTE: and symlink of following to use fonts/icon in flatpak apps
  systemd.tmpfiles.rules = [
    "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
    "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    # "L /usr/share/mime - - - - /run/current-system/sw/share/mime"
  ];
}
