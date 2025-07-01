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
  ];
  environment.systemPackages = with pkgs; [
    adw-gtk3
  ];

}
