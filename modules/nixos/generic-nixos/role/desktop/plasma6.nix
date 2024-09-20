{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    home-manager.sharedModules = [
      (import ../../../../home-manager/plasma6)
      inputs.plasma-manager.homeManagerModules.plasma-manager
    ];

    services.xserver.enable = true;
    services.desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
      # notoPackage = pkgs.noto-fonts-lgc-plus;
    };

    # IME
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc
          fcitx5-hangul
          # fcitx5-m17n
          fcitx5-lua
        ];
      };
    };

    environment.variables = {
      "GLFW_IM_MODULE" = "ibus";
      "SDL_IM_MODULE" = "fcitx";
    };

    # DisplayManager
    services.displayManager.defaultSession = "plasma";

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      settings = {
        Users = {
          RememberLastUser = true;
          RememberLastSession = false;
        };
        General = {
          # GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=144";
          # GreeterEnvironment = "QT_SCREEN_SCALE_FACTORS=1.5";
        };
        Theme = {
          # Current = "";
          # ThemeDir = "${pkgs.xxx}/share/sddm/themes";
        };
      };
    };

    # packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-systemmonitor
    ];

    environment.defaultPackages = builtins.concatLists [
      (with pkgs; [
        # widgets
        compact-pager
        application-title-bar
      ])

      (with pkgs.kdePackages; [
        # image supports in dolphin, ...
        qtimageformats # webp, ...
        kimageformats # avif, jxl, heif, ...
      ])
    ];
    programs = {
      partition-manager.enable = true;
      kde-pim = {
        enable = false;
        kmail = false;
        kontact = false;
        merkuro = true;
      };
      kdeconnect = {
        enable = true;
      };
    };

    /*
    ----
    # NOTE

    * libsForQt5.bismuth
      : dead [2024-06-16](https://github.com/Bismuth-Forge/bismuth)
        Use [polonium](https://github.com/zeroxoneafour/polonium)

    ## Not Usable & plamsa5

    * libsForQt5.plasma-applet-virtual-desktop-bar
    * libsForQt5.plasma-applet-caffeine-plus

    ## plasma5
    * plasma-applet-active-window-control
    * libsForQt5.applet-window-buttons
    * libsForQt5.krunner-symbols
    * inputs.kwin-scripts.packages.${stdenv.system}.virtual-desktops-only-on-primary
    * kwin-script-always-open-on
    ----
    */
  };
}
