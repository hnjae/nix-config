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
  ];

  # https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications#GTK_themes_ported_to_Kvantum
  qt.style = "kvantum";
}
