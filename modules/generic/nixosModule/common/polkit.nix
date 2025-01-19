{lib, ...}: let
  inherit (lib) mkOverride;
in {
  # requires libvirtd to work <NixOS 22.11>
  security.polkit.enable = mkOverride 999 true;
}
