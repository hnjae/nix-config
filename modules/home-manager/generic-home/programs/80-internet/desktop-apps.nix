{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      (optionals genericHomeCfg.installTestApps [
        "org.kde.kasts" # podcast

        # weather
        "io.github.amit9838.mousam"
        # "org.gnome.Weather"

        "io.github.elevenhsoft.WebApps" # cosmic de's webapp creator
        "org.ferdium.Ferdium" # apache 1

        "re.sonny.Tangram"
        "io.gitlab.news_flash.NewsFlash" # rss
        "org.gnome.Fractal" # matrix

        "org.gnome.Maps"

        # chatbots
        # "io.github.koromelodev.mindmate" # chatgpt client,  # NOTE: uses eol library <2024-05-09>
        # "io.github.qwersyk.Newelle"
      ])
      [
        # "org.localsend.localsend_app" # host 에 설치 (firewall 을 열어야해서)
      ]
    ];

    home.packages = builtins.concatLists [
      (optionals (pkgs.stdenv.isLinux) [
        # inputs.bavarder.packages.${pkgs.stdenv.system}.default
      ])
    ];
  };
}
