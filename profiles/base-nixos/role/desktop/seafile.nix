{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    users.users.hnjae.packages = [
      pkgs.seafile-client
    ];

    home-manager.users.hnjae = {
      xdg.configFile."autostart/com.seafile.seafile-applet.desktop" = {
        enable = true;
        # KDE Panel 실행 기다리기 위해 sleep 필요 <NixOS 23.11, KDE 5.27.1>
        text = ''
          [Desktop Entry]
          Categories=Network;FileTransfer;
          Comment=Seafile desktop sync client
          Exec=sh -c 'sleep 1 && exec seafile-applet'
          Icon=seafile
          Name=Seafile
          Type=Application
        '';
      };
    };
  };
}
