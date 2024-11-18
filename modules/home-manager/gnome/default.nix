{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./paperwm.nix
    ./ulauncher.nix
  ];

  home.packages = with pkgs; [
    dconf2nix
    gnomeExtensions.run-or-raise
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      "run-or-raise@edvard.cz"
    ];
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Alt><Super>l"]; # defaults: <Super>l
    };
    "org/gnome/shell/keybindings" = {
      toggle-application-view = []; # @as []
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Shift><Super>q" "<Alt>F4"];
    };

    # "org/gnome/settings-daemon/plugins/media-keys" = {
    #   calculator = lib.hm.gvariant.mkArray ["Favorites"];
    # };
  };
  services.flatpak.packages = [
    # "org.gnome.Calendar"
    # "org.gnome.Contacts"
    # "org.gnome.Geary"
    # "org.gnome.Evolution"
  ];
  stateful.nodes = [
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
