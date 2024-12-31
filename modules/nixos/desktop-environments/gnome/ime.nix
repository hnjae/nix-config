{pkgs, ...}: {
  config = {
    # IME
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        plasma6Support = false;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc-ut
          # fcitx5-anthy
          fcitx5-hangul
          # fcitx5-m17n
          fcitx5-lua
        ];
        # settings = {
        #   # config
        #   globalOptions = {
        #     "Hotkey/TriggerKeys" = {
        #       "0" = "Zenkaku_Hankaku";
        #       "1" = "Hangul";
        #     };
        #     "Hotkey/EnumerateGroupForwardKeys" = {
        #     };
        #     "Hotkey/EnumerateGroupBackwardKeys" = {
        #       "0" = "Control+Shift+space";
        #     };
        #   };
        #   # profile
        #   inputMethod = {
        #     "Groups/0" = {
        #       Name = "ja";
        #       "Default Layout" = "us-colemak_dh";
        #       DefaultIM = "mozc";
        #     };
        #     "Groups/0/Items/0" = {
        #       Name = "keyboard-use-colemak_dh";
        #       Layout = "";
        #     };
        #     "Groups/0/Items/1" = {
        #       Name = "mozc";
        #       Layout = "";
        #     };
        #     "Groups/1" = {
        #       Name = "ko";
        #       "Default Layout" = "us-colemak_dh";
        #       DefaultIM = "hangul";
        #     };
        #     "Groups/1/Items/0" = {
        #       Name = "keyboard-use-colemak_dh";
        #       Layout = "";
        #     };
        #     "Groups/1/Items/1" = {
        #       Name = "hangul";
        #       Layout = "us";
        #     };
        #     "GroupOrder" = {
        #       "0" = "ko";
        #       "1" = "ja";
        #     };
        #   };
        # };
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
          "org/gnome/desktop/input-sources" = {
            # mru-sources=[('xkb', 'us+colemak_dh')];
            # sources=[('xkb', 'us+colemak_dh')];
            xkb-options = [
              # "altwin:swap_lalt_lwin"
              "shift:both_capslock_cancel"
              "caps:backspace"
              "korean:ralt_hangul"
              "korean:rctrl_hanja"
            ];
          };
        };
      }
      ({config, ...}: {
        stateful.nodes = [
          {
            path = "${config.xdg.configHome}/mozc";
            mode = "700";
            type = "dir";
          }
          {
            path = "${config.xdg.configHome}/fcitx5";
            mode = "700";
            type = "dir";
          }
        ];
      })
    ];
    environment.systemPackages = with pkgs.gnomeExtensions; [
      kimpanel # to use with fcitx5
    ];
  };
}
