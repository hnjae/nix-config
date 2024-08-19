# import this unit if xserver.enable
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride;
in {
  xdg.portal.xdgOpenUsePortal = mkOverride 999 true;

  environment.sessionVariables =
    lib.attrsets.optionalAttrs
    config.xdg.portal.xdgOpenUsePortal {
      GTK_USE_PORTAL = "1";
    };

  # NOTE: flatpak requires xdg.portal.enable
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk # 없으면 gtk 앱에서 antialasing+cursor theme 안됨. <NixOS 23.05 & NixOS 24.05>
  ];
}
