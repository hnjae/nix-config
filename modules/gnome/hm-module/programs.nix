{ ... }:
{
  services.flatpak.packages = [
    "org.gnome.Boxes"
    "org.gnome.Loupe"
    "page.tesk.Refine" # Refine helps discover advanced and experimental features in GNOME.
  ];
  default-app.image = "org.gnome.Loupe";
}
