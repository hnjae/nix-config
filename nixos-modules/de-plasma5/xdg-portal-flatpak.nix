# import this unit if xserver.enable
{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride;
in {
  imports = [
  ];

  # services.flatpak-update.enable = mkOverride 999 true;
  # services.flatpak-uninstall-unused.enable = mkOverride 999 true;
  services.flatpak.enable = mkOverride 999 true;

  # https://bbs.archlinux.org/viewtopic.php?id=261143
  systemd.tmpfiles.rules = [
    "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
    "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    # "L /usr/share/mime - - - - /run/current-system/sw/share/mime"
  ];

  xdg.portal.xdgOpenUsePortal = mkOverride 999 true;

  # NOTE: flatpak requires xdg.portal.enable
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    libsForQt5.xdg-desktop-portal-kde

    # xdg-desktop-portal-gtk 없으면 gtk 앱에서 antialasing+cursor theme 안됨. <NixOS 23.05>
    xdg-desktop-portal-gtk
  ];

  fonts.fontDir.enable = true; # <2024-01-23>
  # NOTE: and symlink following to use fonts/icon in flatpak apps
  # .local/share/fonts -> /run/current-system/sw/share/X11/fonts
  # .local/share/icons -> /run/current-system/sw/share/icons
  # TODO: usr/local/share 에 symbolic 하면 어때? <2024-01-23>
}
