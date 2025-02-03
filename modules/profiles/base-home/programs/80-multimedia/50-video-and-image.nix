{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in
{
  home.packages =
    let
      inherit (lib.lists) optionals;
    in
    (builtins.concatLists [
      # (lib.lists.optionals pkgs.stdenv.isLinux (with pkgs.kdePackages; [
      #   okular # flathub's build lacks rar support
      #   gwenview # flathub's build lacks heif support
      # ]))

      (optionals baseHomeCfg.isDesktop (with pkgsUnstable; [ inkscape-with-extensions ]))
      [
        (if baseHomeCfg.isDesktop then pkgs.mkvtoolnix else pkgs.mkvtoolnix-cli)
      ]

      # QT
      # qview # flathub's build lacks heif support
      # qimgv
      # mpc-qt
      # smplayer
    ]);

  default-app.mime = {
    "image/x-xcf" = "org.gimp.GIMP"; # {'*.xcf'}
    "image/vnd.adobe.photoshop" = "org.gimp.GIMP"; # {'*.psd'}
  };

  services.flatpak.packages = lib.lists.optionals baseHomeCfg.isDesktop (
    builtins.concatLists [
      [
        "org.gimp.GIMP"
        "org.kde.kolourpaint" # basic painting
        "org.kde.krita"

        "org.kde.kdenlive"

        "org.darktable.Darktable"
        "org.kde.digikam"

        "org.gnome.Snapshot" # camera
        "io.github.nokse22.asciidraw" # asciidraw, gpl3
      ]
      ([
        # gstreamer based
        "com.github.rafostar.Clapper"
        "net.base_art.Glide"
        "org.gnome.Showtime"

        "com.github.maoschanz.drawing"
        "com.github.PintaProject.Pinta"

        "page.codeberg.Imaginer.Imaginer" # ai image generator
        "org.gnome.design.Emblem" # generate avatar

        # cutvideo
        "org.gnome.gitlab.YaLTeR.VideoTrimmer"

        "org.gnome.gitlab.YaLTeR.Identity" # compare image or video
      ])
    ]
  );
}
