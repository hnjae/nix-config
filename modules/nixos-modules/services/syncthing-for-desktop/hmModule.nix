# homeManagerModule
{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    (pkgs.syncthingtray.override {
      kioPluginSupport = false;
      plasmoidSupport = false;
      systemdSupport = false;
      # webviewSupport = false;
    })
  ];

  xdg.configFile."autostart/syncthingtray.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=Syncthing Tray
      GenericName=Syncthing Tray
      Comment=Tray application for Syncthing
      Exec=syncthingtray --wait
      Icon=syncthingtray
      Terminal=false
      Type=Application
      Categories=Network

      [Desktop Action open-webui]
      Name=Open web UI
      Exec=syncthingtray --webui
    '';
  };
}
