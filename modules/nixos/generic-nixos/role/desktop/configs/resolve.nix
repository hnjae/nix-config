{lib, ...}: let
  inherit (lib) mkOverride;
in {
  # org.freedesktop.resolve1
  services.resolved.enable = mkOverride 999 true;
}
