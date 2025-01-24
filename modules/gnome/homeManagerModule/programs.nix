{ ... }:
{
  services.flatpak.packages = [
    "org.gnome.Boxes"
    "org.gnome.Loupe"
  ];
  default-app.image = "org.gnome.Loupe";
}
