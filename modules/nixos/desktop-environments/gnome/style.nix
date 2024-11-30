{pkgs, ...}: {
  # run
  # `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'`
  services.flatpak.packages = [
    # libadwaita theme on gtk3
    "org.gtk.Gtk3theme.adw-gtk3-dark"
    "org.gtk.Gtk3theme.adw-gtk3"
  ];

  home-manager.sharedModules = [
    {
      dconf.settings = {
        "org/gnome/desktop/interface".gtk-theme = "adw-gtk3";
        "org/gnome/desktop/interface".icon-theme = "MoreWaita";
        "org/gnome/desktop/interface".font-name = "Sans 11";
        "org/gnome/desktop/interface".document-font-name = "Sans 11";
        "org/gnome/desktop/interface".monospace-font-name = "Monospace 10";
      };
    }
    {
      services.flatpak.packages = [
        "org.gtk.Gtk3theme.adw-gtk3-dark"
        "org.gtk.Gtk3theme.adw-gtk3"
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    morewaita-icon-theme # extend adwaita

    # fallback theme for generic-icons (e.g. utilities-system-monitor)
    whitesur-icon-theme
    # paper-icon-theme
    # papirus-icon-theme
  ];

  # gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'

  # https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita";
  };
}
