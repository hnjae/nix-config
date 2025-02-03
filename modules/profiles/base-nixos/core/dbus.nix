{ lib, ... }:
{
  # NOTE:
  # Fedora uses brocker since Fedora 29
  # Ubuntu 23.10 might switch to dbus-brocker
  # https://fedoraproject.org/wiki/Changes/DbusBrokerAsTheDefaultDbusImplementation
  # https://bugzilla.redhat.com/show_bug.cgi?id=1557954
  # https://www.phoronix.com/news/Ubuntu-23.10-Dbus-Broker-Plan

  # NOTE: https://github.com/NixOS/nixpkgs/issues/303078 <2025-01-05>
  services.dbus = {
    apparmor = lib.mkOverride 999 "enabled";
    implementation = lib.mkOverride 999 "dbus";
  };
}
