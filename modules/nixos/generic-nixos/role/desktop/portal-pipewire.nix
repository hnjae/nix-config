# Modern linux platform of wayland era
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOverride;
  isDesktop = config.generic-nixos.role == "desktop";
in {
  config = lib.mkIf isDesktop {
    hardware.pulseaudio.enable = false;

    services.pipewire = {
      enable = mkOverride 999 true;
      wireplumber.enable = mkOverride 999 true;
      audio.enable = mkOverride 999 true;
      alsa.enable = mkOverride 999 true;
      alsa.support32Bit = mkOverride 999 true;
      pulse.enable = mkOverride 999 true;
      jack.enable = mkOverride 999 true;
    };

    environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua" = {
      enable = mkOverride 999 isDesktop;
      text = ''
        bluez_monitor.properties = {
          ["bluez5.a2dp.ldac.quality"] = "sq", -- 660
        }
      '';
      # ["bluez5.a2dp.aac.bitratemode"] = 1,
      # ["bluez5.enable-sbc-xq"] = true,
      # ["bluez5.enable-msbc"] = true,
      # ["bluez5.codecs"] = "[ aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex faststream faststream_duplex ]",
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk # 없으면 gtk 앱에서 antialasing+cursor theme 안됨. <NixOS 23.05 & NixOS 24.05>
    ];

    xdg.portal.xdgOpenUsePortal = mkOverride 999 true;

    environment.sessionVariables =
      lib.attrsets.optionalAttrs
      config.xdg.portal.xdgOpenUsePortal {
        GTK_USE_PORTAL = "1";
      };
  };
}
