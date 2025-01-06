{
  config,
  lib,
  ...
}: {
  imports = [
    ./1password.nix
    ./bluetooth.nix
    ./flatpak.nix
    ./fonts.nix
    ./locate.nix
    ./packages.nix
    ./portal-pipewire.nix
  ];

  config = lib.mkIf (config.generic-nixos.role == "desktop") {
    # NOTE: https://gitlab.freedesktop.org/xorg/xserver/-/issues/1384 <2024-12-12>
    # X11 이나 xwayland 에서 caps:backspace 가 활성화되어 있을시, caps 가 backspace 를 keep-sending 하지 않는 문제 수정
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

    # provides org.freedesktop.upower interface
    services.upower.enable = lib.mkOverride 999 true;
    services.printing.enable = lib.mkOverride 999 true;
    programs.gnupg.agent.enable = lib.mkOverride 999 true;

    documentation.dev.enable = lib.mkOverride 999 true;
  };
}
