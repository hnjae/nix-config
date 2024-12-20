{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    ulauncher
    # albert # albert does not support fuzzy finding
  ];

  # NOTE: ulauncher 을 wayland 로 실행시, 화면 정중앙에 검색창이 뜨질 않는다.  <2024-12-02>
  xdg.configFile."autostart/ulauncher.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Categories=Office;
      Exec=sh -c 'sleep 1 && GDK_BACKEND=x11 ulauncher --hide-window'
      Icon=ulauncher
      Name=ulauncher
      StartupWMClass=ulauncher
      Terminal=false
      Type=Application
    '';
  };
  dconf.settings = {
    # "org/gnome/mutter" = {
    #   center-new-windows = true; # if using wayland
    # };
    #
    "org/gnome/shell/extensions/paperwm".winprops = [
      ''{"wm_class":"Ulauncher","scratch_layer":true,"title":""}''
    ];
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-ulauncher/"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-ulauncher" = {
      binding = "<Super>space";
      command = "ulauncher-toggle";
      name = "run-ulauncher-toggle";
    };
  };
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/ulauncher";
      mode = "755";
      type = "dir";
    }
  ];
}
