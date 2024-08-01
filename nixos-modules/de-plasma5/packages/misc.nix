{pkgs, ...}: {
  environment.defaultPackages = with pkgs; [
    dbus
  ];
}
