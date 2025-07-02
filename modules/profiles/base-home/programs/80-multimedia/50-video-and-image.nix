{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  home.packages = (
    lib.flatten [
      (lib.lists.optionals baseHomeCfg.isDesktop (with pkgsUnstable; [ inkscape-with-extensions ]))
      (if baseHomeCfg.isDesktop then pkgs.mkvtoolnix else pkgs.mkvtoolnix-cli)

      # QT
      # qview # flathub's build lacks heif support
      # qimgv
      # mpc-qt
      # smplayer
    ]
  );

  default-app.mime = {
    "image/x-xcf" = "org.gimp.GIMP"; # {'*.xcf'}
    "image/vnd.adobe.photoshop" = "org.gimp.GIMP"; # {'*.psd'}
  };

  services.flatpak.packages = lib.lists.optionals baseHomeCfg.isDesktop ([
    "org.gimp.GIMP"

    # Painting / Drawing
    "org.kde.krita"
    # "org.kde.kolourpaint" # basic painting
    "com.github.PintaProject.Pinta" # basic painting
    # "com.github.maoschanz.drawing"

    "org.kde.kdenlive"

    "org.darktable.Darktable"
    "org.kde.digikam"

    "org.gnome.Snapshot" # camera
    "io.github.nokse22.asciidraw" # asciidraw, gpl3

    "page.codeberg.Imaginer.Imaginer" # ai image generator
    "org.gnome.design.Emblem" # generate avatar
    "org.gnome.gitlab.YaLTeR.VideoTrimmer" # cut video
    "org.gnome.gitlab.YaLTeR.Identity" # compare image or video
  ]

  );
}
