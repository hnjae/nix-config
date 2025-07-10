/*
  <https://www.arewesixelyet.com/>
    NOTE: wayland-input-protocol 의 한계로 GTK, QT 를 안쓰는 터미널은 한글 입력시 잦은 애로 사항이 있음. <NixOS 23.11>

    NOTE:
      rio: terminal built with rust, no fontconfig, sixel support
      darktile: no wayland support <https://github.com/liamg/darktile/issues/313>
      contour: wayland 에서 폰트 렌더링이 이상함.

    NOTE: cosmic-term  <2024-11-11>
      * https://bbs.archlinux.org/viewtopic.php?id=294816
      * wl_drm#48: error 0: wl_drm.create_prime_buffer is not implemented
      * It seems plasma6 wayland session uses linux-dmabuf(wayland protocol), but AMDVLK/AMDGPU-PRO driver only support wl_drm
*/
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
  imports = [
    ./bottles.nix
    ./warp-terminal
  ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    home.packages = lib.flatten [
      (optionals (pkgs.stdenv.isLinux) [
        pkgs.qdirstat
        pkgsUnstable.resources
        pkgsUnstable.scrcpy # display and control android

        # pkgs.foot
        # pkgs.kitty
        pkgs.wezterm
        pkgsUnstable.ghostty
        (pkgs.runCommandLocal "kitten" { } ''
          mkdir -p "$out/bin"
          ln -s "${pkgs.kitty}/bin/kitten" "$out/bin/kitten"
        '')
      ])

      # pkgs.alacritty
    ];

    default-app.fromApps = [
      # "Alacritty"
      "com.mitchellh.ghostty"
    ];

    services.flatpak.packages = lib.flatten [
      "org.gnome.Logs" # systemd logs, ets
      "com.github.qarmin.czkawka" # <https://github.com/qarmin/czkawka> deduplication

      # infos
      "xyz.tytanium.DoorKnocker" # check availability of all portals provided by xdg-desktop-portal.
      "dev.serebit.Waycheck" # displays the list of Wayland protocols

      "com.github.tchx84.Flatseal" # edit permission of wayland apps

      "com.github.flxzt.rnote" # https://flathub.org/apps/com.github.flxzt.rnote
      "page.codeberg.libre_menu_editor.LibreMenuEditor"

      # infos
      # "io.missioncenter.MissionCenter" # not working <NixOS 23.11>
      # "net.nokyan.Resources" # resource monitor; flatpak's 은 프로세스를 볼수 없음. https://github.com/nokyan/resources/issues/357 2024-09-19

      #
      "org.gnome.font-viewer"
      "org.gnome.Characters"
      "org.gnome.Connections"

      "fr.romainvigier.MetadataCleaner"

      "io.github.giantpinkrobots.flatsweep" # remove leftover of flatpak apps
      "io.github.flattool.Warehouse" # flatpak managing
    ];
  };
}
