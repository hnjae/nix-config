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
    services.flatpak.packages = builtins.concatLists [
      [
        "org.gnome.Maps"
      ]
      (lib.lists.optionals baseHomeCfg.isHome [
        "io.gitlab.news_flash.NewsFlash" # rss, freshrss clients
        "org.ferdium.Ferdium" # apache 1
        "org.gnome.Fractal" # matrix
        "com.discordapp.Discord" # Proprietary
        "com.ticktick.TickTick" # Proprietary, Offline Support 지원 안함. text-input-v3 지원 X <2025-03-21>
      ])
    ];
  };
}
