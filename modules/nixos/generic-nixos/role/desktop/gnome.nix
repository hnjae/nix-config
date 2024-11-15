{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    # IME
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        plasma6Support = false;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc
          fcitx5-hangul
          # fcitx5-m17n
          fcitx5-lua
        ];
      };
    };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;

      # NOTE: extraGSettingsOverrides might be deprecated in future.
      # https://github.com/NixOS/nixpkgs/issues/321438
      # extraGSettingsOverrides = ''
    };

    home-manager.sharedModules = [
      (import ../../../../home-manager/gnome)
      {
        # hide fcitx5-migrator desktop entry
        xdg.desktopEntries."org.fcitx.fcitx5-migrator" = {
          name = "fcitx5-migration-wizard";
          comment = "this should not be displayed";
          exec = ":";
          type = "Application";
          noDisplay = true;
        };
        # hide fcitx5 desktop entry
        xdg.desktopEntries."org.fcitx.Fcitx5" = {
          name = "fcitx5";
          comment = "this should not be displayed";
          exec = ":";
          type = "Application";
          noDisplay = true;
        };
      }
      {
        # with lib.hm.gvariant;
        dconf.settings = {
          /*
          ```
          gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
          gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
          ```
          */
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer"
              "variable-refresh-rate"
              "xwayland-native-scaling"
            ];
          };
        };
      }
    ];

    services.gnome = {
      core-utilities.enable = false; # install core-utilites e.g. nautilus, calculator
      core-shell.enable = true;
      core-os-services.enable = true; # setup portal, polkit, dconf, and etc.
      # tracker.enable = false;
    };
    environment.defaultPackages = with pkgs.gnomeExtensions; [
      paperwm
      run-or-raise
      kimpanel # to use with fcitx5
    ];
    environment.systemPackages = with pkgs; [
      nautilus
      dconf-editor
    ];

    environment.gnome.excludePackages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/x11/desktop-managers/gnome.nix
      gnome-tour
    ];
  };
}
