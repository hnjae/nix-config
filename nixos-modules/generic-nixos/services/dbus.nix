{lib, ...}: {
  # NOTE:
  # Fedora uses brocker since Fedora 29
  # Ubuntu 23.10 might switch to dbus-brocker
  # https://fedoraproject.org/wiki/Changes/DbusBrokerAsTheDefaultDbusImplementation
  # https://bugzilla.redhat.com/show_bug.cgi?id=1557954
  # https://www.phoronix.com/news/Ubuntu-23.10-Dbus-Broker-Plan

  services.dbus.implementation = lib.mkOverride 999 "broker";
  services.dbus.apparmor = "enabled";
}
