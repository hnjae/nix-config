{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./ime.nix
  ];
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;

      # NOTE: extraGSettingsOverrides might be deprecated in future.
      # https://github.com/NixOS/nixpkgs/issues/321438
      # extraGSettingsOverrides = ''
    };

    home-manager.sharedModules = [
      (import ../../../../../home-manager/gnome)
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
