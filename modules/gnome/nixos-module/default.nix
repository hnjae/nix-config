{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./ime.nix
    ./kdeconnect.nix
    ./style
    ./tray.nix
  ];

  config = {
    services.xserver.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.xserver.displayManager.gdm.enable = true;

    security.pam.services.login.enableGnomeKeyring = true;

    services.xserver.desktopManager.gnome = {
      enable = true;

      # NOTE: extraGSettingsOverrides might be deprecated in future.
      # https://github.com/NixOS/nixpkgs/issues/321438
      # extraGSettingsOverrides = ''
    };

    # services.blueman.enable = true; # gnome 47's bluetooth managing is not good

    home-manager.sharedModules = [
      (import ../hm-module)
      {
        # with lib.hm.gvariant;
        dconf.settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer"
              # "variable-refresh-rate" # NOTE: <Gnome 47; NixOS 24.11> not working
              "xwayland-native-scaling"
            ];
          };
          "system/locale" = {
            region = "en_IE.UTF-8";
          };
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-timeout = 5400;
            sleep-inactive-ac-type = "suspend";
          };
        };
      }
      {
        /*
          NOTE: <NixOS 24.11; Gnome 47>
          xdg-desktop-portal-gnome 의 최초 실행이 **매우** 느림. (아마 dbus 가) activate 하는 과정에서 뭐가 문제가 있는 것 같음. 근데 그냥 터미널에서 실행은 빠름. 디버깅 하다가 포기하고 아래 설정으로 임시조치.

          ※ 기대한 동작되로 돌아가지 않음.
        */
        # xdg.configFile."autostart/start-xdg-desktop-portal-gnome.desktop" = {
        #   enable = true;
        #   text = ''
        #     [Desktop Entry]
        #     Exec=sh -c 'sleep 0.5 && systemctl --user start xdg-desktop-portal-gnome.service'
        #     Name=start-xdg-desktop-portal-gnome
        #     Terminal=false
        #     Type=Application
        #   '';
        # };
      }
      # from network-manager
      (
        { config, ... }:
        {
          stateful.nodes = [
            {
              path = "${config.home.homeDirectory}/.pki";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.home.homeDirectory}/.cert";
              mode = "755";
              type = "dir";
            }
            # {
            #   path = "${config.xdg.configHome}/gnome-initial-setup-done";
            #   mode = "644";
            #   type = "file";
            # }
            {
              path = "${config.xdg.configHome}/gnome-session";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.configHome}/goa-1.0";
              mode = "755";
              type = "dir";
            }
            {
              path = "${config.xdg.configHome}/gtk-3.0";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/nautilus";
              mode = "755";
              type = "dir";
            }
            {
              path = "${config.xdg.configHome}/evolution";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/evolution";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/gnome-settings-daemon";
              mode = "755";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/gnome-shell";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/gvfs-metadata";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/keyrings";
              mode = "700";
              type = "dir";
            }
            {
              path = "${config.xdg.dataHome}/icc";
              mode = "755";
              type = "dir";
            }
          ];
        }
      )
      {
        # NOTE: system-wide flatpak 말고 user 사용 (라이브러리 공유)
        services.flatpak.packages = [
          # "org.gnome.Evolution" # Microsoft 의 이메일 처리가 문제 있음. Evolution 으로 타 계정에서 ms로 옮긴 이메일이 ms에서 Drafts 로 인식됨. <Gnome 47; NixOS 24.11>
          "org.gnome.Calendar"
          "org.gnome.Contacts"
          "org.gnome.Geary"
          "org.gnome.Calculator"
        ];
      }
    ];
    programs.file-roller.enable = true; # flatpak's version is unofficial

    services.gnome = {
      core-utilities.enable = false; # install core-utilites e.g. nautilus, calculator
      core-shell.enable = true;
      core-os-services.enable = true; # setup portal, polkit, dconf, and etc.
      # tracker.enable = false;
    };

    # portal 에 geolocation 을 제공하지 않음.
    # services.geoclue2 = {
    #   enable = true;
    #   enable3G = lib.mkOverride 999 false;
    #   enableCDMA = lib.mkOverride 999 false;
    #   enableModemGPS = lib.mkOverride 999 false;
    # };

    environment.gnome.excludePackages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/x11/desktop-managers/gnome.nix
      gnome-tour
      gnome-shell-extensions
    ];

    environment.systemPackages = with pkgs; [
      seahorse # gui of gnome-keyring
      gnome-console
      dconf-editor
      nautilus

      # THUMBNAILS
      /*
        NOTE: <NixOS 24.11>
          following packages does not use absolute nix path in `.thumbnailer`. It requires executables to be in `$PATH`
      */
      gnome-font-viewer
    ];

    nixpkgs.overlays = [
      (final: prev: {
        papers =
          (prev.papers.override {
            supportNautilus = false;
            withLibsecret = false;
          }).overrideAttrs
            (oldAttrs: {
              postInstall = lib.strings.concatLines [
                # NOTE: 아래 이미지는 기본패키징에서는 지원되지 않음을 확인. <Gnome 47; NixOS 24.11>
                # gdk-pixbuf 를 전역에서 바꾸기에는 리컴파일이 너무 잦음
                oldAttrs.postInstall
                ''
                  # Pull in various support of images
                  # In postInstall to run before gappsWrapperArgsHook.
                  export GDK_PIXBUF_MODULE_FILE="${
                    prev.gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
                      extraLoaders = with final; [
                        libopenraw
                        libavif
                        libjxl
                        webp-pixbuf-loader
                        libheif.out
                      ];
                    }
                  }"
                ''
              ];
            });
        nautilus = prev.nautilus.overrideAttrs (oldAttrs: {
          # https://wiki.nixos.org/w/index.php?title=Nautilus&mobileaction=toggle_view_desktop#Gstreamer
          buildInputs = builtins.concatLists [
            oldAttrs.buildInputs
            (with final.gst_all_1; [
              gst-plugins-good
              gst-plugins-bad
              gst-plugins-ugly
            ])
          ];

          preFixup = lib.strings.concatLines [
            oldAttrs.preFixup
            ''
              gappsWrapperArgs+=(
                --prefix XDG_DATA_DIRS : "${final.gnome-epub-thumbnailer}/share"
                --prefix XDG_DATA_DIRS : "${final.gnome-font-viewer}/share"
                --prefix XDG_DATA_DIRS : "${final.papers}/share"
                --prefix XDG_DATA_DIRS : "${final.totem}/share"
              )
            ''
          ];
        });
      })
    ];
  };
}
