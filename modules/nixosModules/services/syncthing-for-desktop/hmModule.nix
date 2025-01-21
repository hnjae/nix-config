# homeManagerModule
{
  config,
  pkgs,
  ...
}: {
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

  # NOTE: syncthingtray.ini 를 plasma-manager로 선언적으로 사용해보려고 해도 connections 정보를 매번 지워버리게 되어 사용할 수 없다. plasma-manager에서 파일 처리 과정 문제로 추정. <2024-06-13>
  stateful.nodes = [
    {
      path = "${config.xdg.configHome}/syncthingtray.ini";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/syncthing";
      mode = "700";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/syncthing";
      mode = "755";
      type = "dir";
    }
  ];
}
