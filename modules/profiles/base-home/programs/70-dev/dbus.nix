{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDev && baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      "org.freedesktop.Bustle" # debug dbus, gpl2
      "org.gnome.dspy" # debug d-bus, gpl3
    ];
  };
}
