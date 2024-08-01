{lib, ...}: let
  inherit (lib) mkOverride;
in {
  security.polkit.enable = mkOverride 999 true; # requires libvirtd to work <NixOS 22.11>
}
