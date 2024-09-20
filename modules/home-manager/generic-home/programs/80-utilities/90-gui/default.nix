{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  imports = [./bottles.nix];

  config = lib.mkIf (genericHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      [
        "org.gnome.Logs" # systemd logs, ets
      ]
      (optionals genericHomeCfg.installTestApps [
        "org.gnome.NetworkDisplays"

        # infos
        "xyz.tytanium.DoorKnocker" # check availability of all portals provided by xdg-desktop-portal.
        "dev.serebit.Waycheck" # displays the list of Wayland protocols
        # "io.missioncenter.MissionCenter" # not working <NixOS 23.11>
        # "net.nokyan.Resources" # resource monitor; flatpak's 은 프로세스를 볼수 없음. https://github.com/nokyan/resources/issues/357 2024-09-19
        "com.github.tchx84.Flatseal"
        "org.freedesktop.Bustle" # debug dbus, gpl2

        #
        "org.gnome.font-viewer"
        "org.gnome.Characters"
        "org.gnome.Connections"

        # "com.github.wwmm.easyeffects"
        "app.drey.Dialect"
        "com.github.vikdevelop.timer" # timer

        # "com.lakoliu.Furtherance" # time tracking app, # NOTE: uses eol library <2024-05-09>

        "im.bernard.Nostalgia" # wallpaper, gpl3

        "fr.romainvigier.MetadataCleaner"
        "app.drey.KeyRack" # edit secrets

        "io.github.giantpinkrobots.flatsweep" # remove leftover of flatpak apps
        "io.github.flattool.Warehouse" # flatpak managing

        "io.github.prateekmedia.appimagepool"
      ])
    ];

    home.packages = builtins.concatLists [
      (optionals (pkgs.stdenv.isLinux) [
        # pkgs.dupeguru
        pkgs.qdirstat
        pkgsUnstable.resources
      ])
      (optionals (pkgs.stdenv.isLinux && genericHomeCfg.installTestApps)
        (with pkgs; [
          clipboard-jh
          distrobox
          poppler_utils # pdftotext
          # ffmpegthumbnailer
        ]))
    ];
    stateful.cowNodes = [
      {
        path = "${config.xdg.dataHome}/icons/distrobox";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
