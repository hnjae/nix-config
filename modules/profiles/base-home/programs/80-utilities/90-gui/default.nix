{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in
{
  imports = [ ./bottles.nix ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      [
        "org.gnome.clocks"
        "org.gnome.Logs" # systemd logs, ets
        "app.drey.KeyRack" # edit secrets
        "com.github.qarmin.czkawka" # <https://github.com/qarmin/czkawka> deduplication

        # infos
        "xyz.tytanium.DoorKnocker" # check availability of all portals provided by xdg-desktop-portal.
        "dev.serebit.Waycheck" # displays the list of Wayland protocols

        "com.github.tchx84.Flatseal" # edit permission of wayland apps
      ]

      ([
        # "org.gnome.NetworkDisplays"
        "com.github.flxzt.rnote" # https://flathub.org/apps/com.github.flxzt.rnote
        "page.codeberg.libre_menu_editor.LibreMenuEditor"

        # infos
        # "io.missioncenter.MissionCenter" # not working <NixOS 23.11>
        # "net.nokyan.Resources" # resource monitor; flatpak's 은 프로세스를 볼수 없음. https://github.com/nokyan/resources/issues/357 2024-09-19

        #
        "org.gnome.font-viewer"
        "org.gnome.Characters"
        "org.gnome.Connections"

        # "com.github.wwmm.easyeffects"
        "app.drey.Dialect"
        "com.github.vikdevelop.timer" # timer

        # "com.lakoliu.Furtherance" # time tracking app, # NOTE: uses eol library <2024-05-09>

        # "im.bernard.Nostalgia" # wallpaper, gpl3

        "fr.romainvigier.MetadataCleaner"

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
        pkgsUnstable.scrcpy # display and control android
        pkgsUnstable.ulauncher
      ])
    ];
  };
}
