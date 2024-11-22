{
  pkgs,
  config,
  lib,
  ...
}: {
  config =
    lib.mkIf (config.generic-nixos.role == "desktop")
    {
      # localsend
      networking.firewall = {
        allowedTCPPorts = [53317];
        allowedUDPPorts = [53317];
      };
      services.flatpak.packages = [
        "org.localsend.localsend_app" # should open 53317
      ];
      services.flatpak.overrides."org.localsend.localsend_app" = {
        Context = {filesystems = ["xdg-download"];};
        # Environment = {
        #   "GTK_THEME" = "adw-gtk3";
        # };
      };

      # managing android
      programs.adb.enable = true;

      # managing external displays <https://wiki.archlinux.org/title/Backlight>
      services.ddccontrol.enable = true;

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
