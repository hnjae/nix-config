_: {
  # NOTE: wayland 이고, virtual-keyborad 설정이 제대로 되었다면 별도의 fcitx5 자동 실행은 필요없음.
  # faild-units 에 뜨는걸 제거하기  위해, /etc/xdg/ 파일 오버라이드 <NixOS 23.11>
  xdg.configFile."autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    NoDisplay=true
    Exec=:
    Name=This should not be displayed
    Type=Application
  '';
}
