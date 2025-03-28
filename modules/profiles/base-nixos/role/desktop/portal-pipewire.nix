# Modern linux platform of wayland era
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOverride;
  isDesktop = config.base-nixos.role == "desktop";
in
{
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

    # DE 관련 모듈에서 설정할 것.
    # xdg.portal.xdgOpenUsePortal = mkOverride 999 true;
    #
    # environment.sessionVariables =
    #   lib.attrsets.optionalAttrs
    #   config.xdg.portal.xdgOpenUsePortal {
    #     GTK_USE_PORTAL = "1";
    #   };
  };
}
