{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./ime.nix
    ./style.nix
    ./tray.nix
  ];

  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    services.xserver.enable = true;
    services.xserver.excludePackages = [pkgs.xterm];
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;

      # NOTE: extraGSettingsOverrides might be deprecated in future.
      # https://github.com/NixOS/nixpkgs/issues/321438
      # extraGSettingsOverrides = ''
    };

    home-manager.sharedModules = [
      (import ../../../home-manager/gnome)
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
      # from network-manager
      ({config, ...}: {
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
      })
    ];

    services.gnome = {
      core-utilities.enable = false; # install core-utilites e.g. nautilus, calculator
      core-shell.enable = true;
      core-os-services.enable = true; # setup portal, polkit, dconf, and etc.
      # tracker.enable = false;
    };
    xdg.portal.extraPortals = lib.mkForce [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    environment.systemPackages = with pkgs; [
      nautilus
      dconf-editor
      gnome-console
      #
      # services.gnome.gnome-online-accounts.enable = mkDefault true;
      #
      # gnome-calendar
      # gnome-contacts
    ];
    services.flatpak.packages = [
      "org.gnome.Calendar"
      "org.gnome.Contacts"
      # "org.gnome.Evolution" # Microsoft 의 이메일 처리가 문제 있음. Evolution 으로 타 계정에서 ms로 옮긴 이메일이 ms에서 Drafts 로 인식됨. <Gnome 47; NixOS 24.11>
      "org.gnome.Geary"
    ];
    # programs.geary.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/x11/desktop-managers/gnome.nix
      gnome-tour
      gnome-shell-extensions
    ];
  };
}
