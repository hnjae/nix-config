{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    # programs.localsend.enable = true;
    # localsend
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };

    home-manager.sharedModules = [
      {
        # NOTE: system-wide flatpak 말고 user 사용 (라이브러리 공유)
        services.flatpak.packages = [
          # font 깨짐 <NixOS 25.05>
          "org.localsend.localsend_app" # should open 53317
        ];
        services.flatpak.overrides."org.localsend.localsend_app" = {
          Context = {
            filesystems = [
              "home"
              "!xdg-config"
              # "xdg-download"
              # "xdg-public-share"
              # "xdg-pictures"
              # "xdg-desktop"
              # "xdg-documents"
              # "xdg-videos"
              # "xdg-music"
            ];
          };
        };
      }
    ];

    # Run unpatched dynamic binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      icu # marksman requires
    ];

    # managing android
    programs.adb.enable = true;

    # managing external displays <https://wiki.archlinux.org/title/Backlight>
    services.ddccontrol.enable = true;

    environment.defaultPackages = with pkgs; [
      (appimage-run.override {
        extraPkgs =
          pkgs: with pkgs; [
            libthai
            # libsecret
          ];
      })

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
    ];
  };
}
