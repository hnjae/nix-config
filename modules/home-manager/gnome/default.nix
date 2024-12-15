{pkgs, ...}: {
  imports = [
    ./programs.nix
    # ./paperwm.nix
    ./ulauncher.nix
  ];

  home.packages = with pkgs; [
    dconf2nix
    # gnomeExtensions.run-or-raise
    gnomeExtensions.caffeine

    gnomeExtensions.blur-my-shell

    gnomeExtensions.dock-from-dash
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    gnomeExtensions.removable-drive-menu

    gnomeExtensions.tiling-shell
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      # "run-or-raise@edvard.cz"
      "caffeine@patapon.info"
    ];
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };

    # keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Alt><Super>l"]; # defaults: <Super>l
    };
    "org/gnome/shell/keybindings" = {
      toggle-application-view = []; # @as []
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Shift><Super>q" "<Alt>F4"];
      begin-resize = ["<Super>r " "<Alt>F8"];
      begin-move = ["<Super>c" "<Alt>F7"];
      show-desktop = ["<Super>d"]; # defaults on Gnome 47: no key binding

      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = ["<Alt>Tab" "<Super>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab" "<Shfit><Super>Tab"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      calculator = ["Favorites"];
    };

    # "org/gnome/settings-daemon/plugins/media-keys" = {
    #   calculator = lib.hm.gvariant.mkArray ["Favorites"];
    # };
  };
}
