{lib, ...}: let
  inherit (lib) mkOverride;
in {
  # printing
  services.printing.enable = mkOverride 999 true;
}