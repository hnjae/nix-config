{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./paperwm.nix
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
      toggle-overview = ["<Super>w"];
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
}
