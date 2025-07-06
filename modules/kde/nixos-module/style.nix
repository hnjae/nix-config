{ pkgs, ... }:
{

  home-manager.sharedModules = [
    {
      services.flatpak.packages = [
        # libadwaita theme on gtk3
        "org.gtk.Gtk3theme.adw-gtk3-dark"
        "org.gtk.Gtk3theme.adw-gtk3"
      ];
    }
    {
      dconf.settings = {
        # `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'`
        "org/gnome/desktop/interface".gtk-theme = "adw-gtk3";
        # "org/gnome/desktop/interface".font-name = "Sans 11";
        # "org/gnome/desktop/interface".document-font-name = "Sans 11";
        # "org/gnome/desktop/interface".monospace-font-name = "Monospace 10";
      };
    }
  ];
  environment.systemPackages = with pkgs; [
    adw-gtk3
  ];

}
