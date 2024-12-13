{...}: {
  imports = [
    ./1password.nix
    ./bluetooth.nix
    ./documentation.nix
    ./flatpak.nix
    ./fonts.nix
    ./gnupg.nix
    ./locate.nix
    ./packages.nix
    ./portal-pipewire.nix
    ./printing.nix
    ./upower.nix
  ];

  # NOTE: https://gitlab.freedesktop.org/xorg/xserver/-/issues/1384 <2024-12-12>
  # X11 이나 xwayland 에서 caps:backspace 가 활성화되어 있을시, caps 가 backspace 를 keep-sending 하지 않는 문제 수정
  # xset r 66
  home-manager.sharedModules = [
    {
      xdg.configFile."autostart/fix-xwayland-ctrl-backspace.desktop" = {
        enable = true;
        text = ''
          [Desktop Entry]
          Exec=sh -c 'sleep 0.2 && xset r 66'
          Name=fix-xwayland-ctrl-backspace
          Terminal=false
          Type=Application
        '';
      };
    }
  ];
}
