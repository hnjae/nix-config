# TODO: launch flatpak apps with kvantum enabled  <2024-12-17>
{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      dconf.settings = {
        # `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'`
        "org/gnome/desktop/interface".gtk-theme = "adw-gtk3";
        "org/gnome/desktop/interface".icon-theme = "MoreWaita";
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
    {
      # ~/.local/share/flatpak/overrides
      services.flatpak.overrides = {
        "global" = {Context = {filesystems = ["xdg-config/Kvantum:ro"];};};
      };
    }
    ({config, ...}: {
      stateful.nodes = [
        {
          path = "${config.xdg.configHome}/kvantum";
          mode = "755";
          type = "dir";
        }
        {
          path = "${config.xdg.configHome}/qt5ct";
          mode = "755";
          type = "dir";
        }
        {
          path = "${config.xdg.configHome}/qt6ct";
          mode = "755";
          type = "dir";
        }
      ];
    })
  ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    morewaita-icon-theme # extend adwaita

    # fallback theme for generic-icons (e.g. utilities-system-monitor)
    whitesur-icon-theme
    # paper-icon-theme
    # papirus-icon-theme
  ];

  # https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
  qt = {
    enable = true;
    style = "kvantum";
    # platformTheme = "qt5ct";
  };
}
