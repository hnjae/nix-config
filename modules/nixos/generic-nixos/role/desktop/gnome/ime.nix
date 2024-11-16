{
  pkgs,
  lib,
  config,
  ...
}: {
  config =
    lib.mkIf (
      config.services.xserver.desktopManager.gnome.enable
    ) {
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
      home-manager.sharedModules = [
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
          dconf.settings = {
            "org/gnome/shell".enabled-extensions = [
              "kimpanel@kde.org"
            ];
            "org/gnome/desktop/wm/keybindings" = {
              # disable ibus switch shortcuts
              switch-input-source = [];
              switch-input-source-backward = [];
            };
          };
        }
      ];
      environment.systemPackages = with pkgs.gnomeExtensions; [
        kimpanel # to use with fcitx5
      ];
    };
}
