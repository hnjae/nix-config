{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ./package {})
  ];
  xdg.configFile."autostart/caffeine.desktop" = {
    enable = true;
    # KDE Panel 실행 기다리기 위해 sleep 필요 (NixOS 23.11, KDE 5.27.1)
    text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Icon=caffeine
      Name=Caffeine-ng
      Comment=Temporarily deactivate the screensaver and sleep mode
      Exec=sh -c 'sleep 1 && caffeine'
      Terminal=false
      Type=Application
      Categories=Utility;TrayIcon;DesktopUtility
      Keywords=Screensaver,Power,DPMS,Blank,Idle
      StartupNotify=false
    '';
    # Exec=sh -c 'sleep 1 && unset GTK_USE_PORTAL && GTK_IM_MODULE=xim 1password --silent'
  };
}
