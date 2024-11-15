{pkgs, ...}: let
  gnomeApps = with pkgs.gnome; [
    dconf-editor
    gnome-tweaks
    gnome-terminal
    adwaita-icon-theme
  ];
  gnomeExtensions = with pkgs.gnomeExtensions; [
    appindicator
    tray-icons-reloaded
    # kimpanel
    blur-my-shell
    # gsconnect
    caffeine
    weather-oclock # show weather using gnome-weather
    dash-to-panel # won't work with blur-my-shell
    date-menu-formatter
  ];
  themes = with pkgs; [
    adw-gtk3
    bibata-cursors
  ];
in {
  # i18n.inputMethod = {
  #   enabled = "ibus";
  #   ibus.engines = with pkgs.ibus-engines; [ mozc hangul m17n kkc ];
  # };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    # https://nixos.org/manual/nixos/stable/index.html#sec-gnome-gsettings-overrides
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      scaling-factor=2
    '';
  };

  environment.gnome.excludePackages =
    (with pkgs.gnome; [
      totem
      geary
      baobab
      gnome-calculator
      gnome-music
      gnome-contacts
      gnome-calendar
    ])
    ++ (with pkgs.gnomeExtensions; [user-themes])
    ++ (with pkgs; [gnome-photos gnome-console]);

  services.gnome.gnome-browser-connector.enable = true;
  qt.platformTheme = "gnome";
  programs.dconf.enable = true;

  # services.gnome.evolution-data-server.enable = false;
  programs.evolution.enable = false;

  programs.kdeconnect = {
    enable = false;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.systemPackages = gnomeApps ++ themes ++ gnomeExtensions;
}
