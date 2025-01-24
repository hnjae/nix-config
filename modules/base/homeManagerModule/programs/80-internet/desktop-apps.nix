{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      "org.ferdium.Ferdium" # apache 1
      "io.gitlab.news_flash.NewsFlash" # rss, freshrss clients
      "org.gnome.Fractal" # matrix

      "org.gnome.Maps"
    ];
  };
}
