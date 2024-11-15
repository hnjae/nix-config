{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  home.packages = let
    inherit (lib.lists) optionals;
  in (builtins.concatLists [
    # (lib.lists.optionals pkgs.stdenv.isLinux (with pkgs.kdePackages; [
    #   okular # flathub's build lacks rar support
    #   gwenview # flathub's build lacks heif support
    # ]))

    (optionals genericHomeCfg.isDesktop
      (with pkgsUnstable; [inkscape-with-extensions]))
    [
      (
        if genericHomeCfg.isDesktop
        then pkgs.mkvtoolnix
        else pkgs.mkvtoolnix-cli
      )
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

  services.flatpak.packages =
    lib.lists.optionals genericHomeCfg.isDesktop
    (builtins.concatLists [
      [
        "org.gimp.GIMP"
        "org.kde.kolourpaint" # basic painting
        "org.kde.krita"

        "org.kde.kdenlive"

        "org.darktable.Darktable"
        "org.kde.digikam"

        "org.gnome.Snapshot" # camera
      ]
      (optionals genericHomeCfg.installTestApps [
        "com.github.maoschanz.drawing"
        "com.github.PintaProject.Pinta"

        "io.github.nokse22.asciidraw" # asciidraw, gpl3
        "page.codeberg.Imaginer.Imaginer" # ai image generator
        "org.gnome.design.Emblem" # generate avatar

        # "io.github.nyre221.kiview" # Apple's Quick Look and Gnome Sushi for kde. # uses end-of-life library (org.kde.Platform branch 6.6)(2024-11-06)
        # requires https://github.com/Nyre221/Kiview

        # cutvideo
        "com.ozmartians.VidCutter"
        "org.gnome.gitlab.YaLTeR.VideoTrimmer"

        # video edting
        # "org.shotcut.Shotcut"

        "org.gnome.gitlab.YaLTeR.Identity" # compare image or video
      ])
    ]);
}
