{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    # IME
    i18n.inputMethod = {
      type = "fcitx5";
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

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;
    };
    services.gnome = {
      core-utilities.enable = false; # install core-utilites
      # core-shell.enable = true;
      core-os-services.enable = true; # setup portal and etc.
      # tracker.enable = false;
    };
    environment.defaultPackages = with pkgs.gnomeExtensions; [
      paperwm
      run-or-raise
    ];
  };
}
