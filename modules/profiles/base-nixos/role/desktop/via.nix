{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";
in
{
  config = lib.mkIf (isDesktop && config.base-nixos.hostType == "baremetal") {
    environment.defaultPackages = with pkgs; [ via ];

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
