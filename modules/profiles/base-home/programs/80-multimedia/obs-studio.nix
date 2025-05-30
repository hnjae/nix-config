{
  pkgs,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    # programs.obs-studio = {
    #   enable = baseHomeCfg.isDesktop && pkgs.stdenv.isLinux;
    #   package = pkgsUnstable.obs-studio;
    #   plugins = with pkgsUnstable.obs-studio-plugins; [
    #     obs-vaapi
    #     obs-gstreamer
    #     obs-vkcapture
    #     obs-pipewire-audio-capture
    #   ];
    # };
    services.flatpak.packages = [
      "com.obsproject.Studio"
    ];
  };
}
