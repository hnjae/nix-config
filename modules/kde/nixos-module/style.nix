{ pkgs, ... }:
{

  home-manager.sharedModules = [
    {
      dconf.settings = {
        # `gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'`
        # "org/gnome/desktop/interface".gtk-theme = "adw-gtk3";

        # "org/gnome/desktop/interface".font-name = "Sans 11";
        # "org/gnome/desktop/interface".document-font-name = "Sans 11";
        # "org/gnome/desktop/interface".monospace-font-name = "Monospace 10";
      };
    }
  ];
  environment.systemPackages = with pkgs; [
    adw-gtk3
    # ((import ./packages/fluent-icon-minimal) { inherit pkgs; })
    # kora-icon-theme
    # whitesur-icon-theme
  ];
}
