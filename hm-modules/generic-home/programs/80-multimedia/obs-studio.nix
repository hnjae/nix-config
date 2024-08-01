{
  pkgs,
  pkgsUnstable,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  programs.obs-studio = {
    enable = genericHomeCfg.isDesktop && pkgs.stdenv.isLinux;
    package = pkgsUnstable.obs-studio;
    plugins = with pkgsUnstable.obs-studio-plugins; [
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
