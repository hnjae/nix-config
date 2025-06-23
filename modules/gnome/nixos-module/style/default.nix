{ pkgs, ... }:
{
  imports = [
    ./kvantum.nix
  ];

  home-manager.sharedModules = [
    {
      dconf.settings = {
        # `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'`
        "org/gnome/desktop/interface".gtk-theme = "adw-gtk3";
        # "org/gnome/desktop/interface".icon-theme = "MoreWaita";
        "org/gnome/desktop/interface".font-name = "Sans 11";
        "org/gnome/desktop/interface".document-font-name = "Sans 11";
        "org/gnome/desktop/interface".monospace-font-name = "Monospace 10";
      };
    }
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
    morewaita-icon-theme # extend adwaita

    # fallback theme for generic-icons (e.g. utilities-system-monitor)
    # NOTE: fallback 이 내가 생각한 대로 작동하지 않는다. <2025-02-06>
    # whitesur-icon-theme
  ];
}
