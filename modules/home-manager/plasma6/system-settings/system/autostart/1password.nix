_: {
  xdg.configFile."autostart/1password.desktop" = {
    enable = true;
    # KDE Panel 실행 기다리기 위해 sleep 필요 (NixOS 23.11, KDE 5.27.1)
    text = ''
      [Desktop Entry]
      Categories=Office;
      Comment=Password manager and secure wallet
      Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent'
      Icon=1password
      MimeType=x-scheme-handler/onepassword;
      Name=1Password
      StartupWMClass=1Password
      Terminal=false
      Type=Application
    '';
    # Exec=sh -c 'sleep 1 && unset GTK_USE_PORTAL && GTK_IM_MODULE=xim 1password --silent'
    # Exec=sh -c 'sleep 1 && GTK_USE_PORTAL=0 1password --silent --enable-features=UseOzonePlatform --ozone-platform-hint=auto --enable-wayland-ime'
  };
}
