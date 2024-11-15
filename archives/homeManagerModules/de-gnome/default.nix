_: {
  dconf.settings."org/gnome/tweaks"."show-extensions-notice" = false;
  dconf.settings."org/gnome/desktop/peripherals/mouse"."natural-scroll" = true;

  # ui
  # dconf.settings."org/gnome/desktop/calendar"."show-weekdate" = true;
  dconf.settings."org/gnome/desktop/interface" = {
    # "document-font-name" = "Pretendard 11";
    # "monospace-font-name" = "MesloLGM Nerd Font Mono 11";
    "document-font-name" = "Sans 11";
    "monospace-font-name" = "Monospace 11";
    "gtk-theme" = "adw-gtk3-dark";
  };

  # gnome-desktop
  dconf.settings."org/gnome/desktop/wm/keybindings" = {
    # "switch-input-source" = [ "Hangul" ];
    # "switch-input-source-backward" = [ "<Shift>Hangul" ];
    "switch-to-workspace-1" = ["<Super>1"];
    "switch-to-workspace-2" = ["<Super>2"];
    "switch-to-workspace-3" = ["<Super>3"];
    "switch-to-workspace-4" = ["<Super>4"];
    "switch-to-workspace-5" = ["<Super>5"];
    "move-to-workspace-1" = ["<Shift><Super>1"];
    "move-to-workspace-2" = ["<Shift><Super>2"];
    "move-to-workspace-3" = ["<Shift><Super>3"];
    "move-to-workspace-4" = ["<Shift><Super>4"];
    "move-to-workspace-5" = ["<Shift><Super>5"];
  };

  # workspace
  dconf.settings."org/gnome/desktop/wm/preferences"."num-workspaces" = 5;
  dconf.settings."org/gnome/mutter"."dynamic-workspaces" = false;

  dconf.settings."org/gnome/mutter"."experimental-features" = ["scale-monitor-framebuffer"];
  dconf.settings."org/gnome/mutter" = {
    "edge-tiling" = true;
    "workspaces-only-on-primary" = true;
  };

  dconf.settings."org/gnome/shell/app-switcher"."current-workspace-only" = true;
  # dconf.settings."org/gnome/shell"."favorite-apps" = true;

  dconf.settings."org/gnome/desktop/privacy" = {
    # "old-files-age" = 14; # not working
    "recent-files-max-age" = 7;
    "remove-old-tmp-files" = true;
    "remove-old-trash-files" = true;
  };

  #
  dconf.settings."org/freedesktop/ibus/engine/hangul" = {
    "auto-reorder" = true;
    "hangul-keyboard" = "3f";
    "hanja-keys" = "Hangul_Hanja,F9";
    "initial-input-mode" = "hangul";
    "switch-keys" = "";
    "word-commit" = false;
  };

  dconf.settings."org/gnome/system/location"."enabled" = true;

  dconf.settings."system/locale"."region" = "en_IE.UTF-8";
}
