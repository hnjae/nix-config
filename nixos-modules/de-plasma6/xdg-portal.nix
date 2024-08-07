# import this unit if xserver.enable
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride;
in {
  xdg.portal.xdgOpenUsePortal = mkOverride 999 true;

  # NOTE: flatpak requires xdg.portal.enable
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    # libsForQt5.xdg-desktop-portal-kde

    xdg-desktop-portal-gtk # 없으면 gtk 앱에서 antialasing+cursor theme 안됨. <NixOS 23.05>
  ];
}
