{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    # Run unpatched dynamic binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      icu # marksman requires
    ];

    # managing android
    programs.adb.enable = true;

    home-manager.sharedModules = [
      {
        default-app.browser = "firefox";
      }
    ];

    environment.defaultPackages = with pkgs; [
      firefox
      vdhcoapp
      chromium

      (appimage-run.override {
        extraPkgs =
          pkgs: with pkgs; [
            libthai
            # libsecret
          ];
      })

      glib # for gio

      # xev
      # xorg.xev
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
    ];
  };
}
