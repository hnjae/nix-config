# Modern linux platform of wayland era
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  isDesktop = config.generic-nixos.role == "desktop";
in {
  config = lib.mkIf isDesktop {
    hardware.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = mkOverride 999 true;

    environment.sessionVariables =
      lib.attrsets.optionalAttrs
      config.xdg.portal.xdgOpenUsePortal {
        GTK_USE_PORTAL = "1";
      };
  };
}
