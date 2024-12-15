{pkgs, ...}: {
  imports = [
    ./programs.nix
    # ./paperwm.nix
    ./ulauncher.nix
    ./dash.nix
  ];

  home.packages = with pkgs; [
    dconf2nix
    # gnomeExtensions.run-or-raise
    gnomeExtensions.caffeine

    gnomeExtensions.blur-my-shell

    gnomeExtensions.removable-drive-menu

    gnomeExtensions.tiling-shell
  ];

  default-app.fileManager = "org.gnome.Nautilus";

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

      # Worskpace
      switch-to-workspace-1 = ["<Super>Home" "<Super>F1"];
      switch-to-workspace-2 = ["<Super>F2"];
      switch-to-workspace-3 = ["<Super>F3"];
      switch-to-workspace-4 = ["<Super>F4"];
      move-to-workspace-1 = ["<Shift><Super>Home" "<Shift><Super>F1"];
      move-to-workspace-2 = ["<Shift><Super>F2"];
      move-to-workspace-3 = ["<Shift><Super>F3"];
      move-to-workspace-4 = ["<Shift><Super>F4"];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      calculator = ["Favorites"];
    };

    # "org/gnome/settings-daemon/plugins/media-keys" = {
    #   calculator = lib.hm.gvariant.mkArray ["Favorites"];
    # };
  };
}
