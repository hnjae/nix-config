# Modern linux platform of wayland era
{
  config,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";
in
{
  config = lib.mkIf isDesktop {
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
  };
}
