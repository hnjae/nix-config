{
  pkgs,
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf (config.generic-nixos.role == "desktop")
    {
      # managing android
      programs.adb.enable = true;

      environment.defaultPackages = with pkgs; [
        glib # for gio

        # xev
        xorg.xev
        wev

        # common tools
        wl-clipboard
        xclip
        xsel
        wmctrl
        libnotify # notify-send command

        # for qt apps (such as contour)
        # qt6.qtwayland
        # libsForQt5.qt5.qtwayland

        # infos
        clinfo # opencl
        glxinfo
        vulkan-tools
        wayland-utils
        xorg.xdpyinfo
        libva-utils

        # gui apps
        xdg-terminal-exec

        kdiskmark

        # webp support in various programs
        # gdk-pixbuf
        # webp-pixbuf-loader

        # others
        ddcutil
        ddcui

        #
        # wlprop # xprop for wlroots

        (appimage-run.override {
          extraPkgs = pkgs:
            with pkgs; [
              libthai
              # libsecret
            ];
        })
      ];
    };
}
