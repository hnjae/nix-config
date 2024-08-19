{lib, ...}: let
  inherit (lib) mkOverride;
in {
  # provides org.freedesktop.upower interface
  services.upower.enable = mkOverride 999 true;
}
