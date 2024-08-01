{
  self,
  pkgs,
  ...
}: let
  dmInUse = "sddm";
in {
  # TODO: check https://github.com/NixOS/nixpkgs/issues/54150 in next release <NixOS 23.11>
  # https://discourse.nixos.org/t/need-help-for-nixos-gnome-scaling-settings/24590/5

  # home-manager.users.gdm = {lib, ...}: {
  #   home = {
  #     username = "gdm";
  #     stateVersion = "23.11";
  #     # homeDirectory = "/var/run/gdm";
  #   };
  #   dconf.settings = {
  #     "org/gnome/desktop/interface" = {
  #       scaling-factor = lib.hm.gvariant.mkUint32 2;
  #     };
  #   };
  # };

  services.displayManager.defaultSession = "plasmawayland";

  # NOTE: gdm 을 사용하면 일부 환경변수를 startplasma-wayland 에 전달하지 않고
  # 실행한다. <2024-02-21; NixOS 23.11>
  services.xserver.displayManager.gdm = {
    enable = dmInUse == "gdm";
    wayland = true;
    banner = "Hi!";
  };

  # TODO: following codes does not work as intended <2023-12-22>
  # NOTE: this code should be updated on every nixos upgrades <2023-12-22>
  # https://discourse.nixos.org/t/need-help-for-nixos-gnome-scaling-settings/24590/5
  # based on https://github.com/NixOS/nixpkgs/blob/23.11/nixos/modules/services/x11/display-managers/gdm.nix
  # programs.dconf.profiles.gdm.databases = lib.mkForce (lib.optionals (!config.services.xserver.displayManager.gdm.autoSuspend) [{
  #   settings."org/gnome/settings-daemon/plugins/power" = {
  #     sleep-inactive-ac-type = "nothing";
  #     sleep-inactive-battery-type = "nothing";
  #     sleep-inactive-ac-timeout = lib.gvariant.mkInt32 0;
  #     sleep-inactive-battery-timeout = lib.gvariant.mkInt32 0;
  #   };
  # }] ++ lib.optionals (config.services.xserver.displayManager.gdm.banner != null) [{
  #   settings."org/gnome/login-screen" = {
  #     banner-message-enable = true;
  #     banner-message-text = config.services.xserver.displayManager.gdm.banner;
  #   };
  # }] ++ [ "${pkgs.gnome.gdm}/share/gdm/greeter-dconf-defaults" ] ++ [
  #   {
  #     settings."org/gnome/desktop/interface" = {
  #       # https://gitlab.gnome.org/GNOME/gsettings-desktop-schemas/blob/b0b0ebf551d0284e285cad9f95c8640dd3f5612e/schemas/org.gnome.desktop.interface.gschema.xml.in#L122
  #       scaling-factor = lib.gvariant.mkInt32 2;
  #     };
  #   }
  #   {
  #     settings."org/gnome/peripherals/touchpad" = {
  #       tap-to-click = true;
  #     };
  #   }
  # ]);

  # services.greetd = {
  #   enable = dmInUse == "greetd";
  #   settings = {
  #     default_session = {
  #       # command = "cage -s -- regreet";
  #       # command = "${pkgs.greetd.greetd}/bin/agreety --cmd startplasma-wayland";
  #     };
  #   };
  # };

  # NOTE: regreet module will configure greetd <NixOS 23.11>
  programs.regreet = {
    enable = dmInUse == "regreet";
    cageArgs = ["-s" "-m" "last"];
  };
  services.greetd.settings.default_session.user = self.val.home.username;

  services.displayManager.sddm = {
    enable = dmInUse == "sddm";
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
        # ThemeDir = "${pkgs.libsForQt5.sddm}/share/sddm/themes";
        # Current = "chili";
        # ThemeDir = "${pkgs.sddm-chili-theme}/share/sddm/themes";
      };
    };
  };

  services.xserver.displayManager.lightdm = let
    iconTheme = {
      # package = pkgs.icon-theme-fluent;
      package = pkgs.fluent-icon-theme;
      name = "Fluent_dark";
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    cursorTheme = {
      # package = pkgs.bibata-cursors;
      # name = "Bibata-Modern-Ice";
      package = pkgs.libsForQt5.breeze-qt5;
      name = "Breeze_Snow";
    };
  in {
    enable = dmInUse == "lightdm";
    # greeters.mobile.enable = true;

    greeters.gtk = {
      enable = true;
      clock-format = "%Y-%m-%d %H:%M:%S";
      inherit iconTheme theme cursorTheme;
      # extraConfig = ''
      #   xft-antialias=true
      #   xft-dpi=96
      #   xft-hintstyle=slight
      # '';
    };
    greeters.slick = {
      enable = false;
      font = {
        package = pkgs.pretendard;
        name = "Pretendard 11";
      };
      inherit iconTheme theme cursorTheme;
      # https://github.com/linuxmint/slick-greeter
      # extraConfig = ''
      #     xft-dpi=192
      #     enable-hidpi=on
      #     play-ready-sound=true
      #     screen-reader=false
      #     show-a11y=false
      #     draw-grid=true
      # '';
    };
  };
}
