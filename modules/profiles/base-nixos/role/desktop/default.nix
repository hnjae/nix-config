{
  config,
  lib,
  ...
}:
{
  imports = [
    ./1password.nix
    ./flatpak.nix
    ./fonts.nix
    ./hardware.nix
    ./libvirtd.nix
    ./locate.nix
    ./packages.nix
    ./portal-pipewire.nix
    ./via.nix
  ];

  config = lib.mkIf (config.base-nixos.role == "desktop") {
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

    i18n.supportedLocales = [
      # add more locales to system
      "ko_KR.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];

    boot.kernel.sysctl = {
      # NOTE: 강제 재부팅을 위해서는 1 이 되어야 함. <NixOS 24.05>
      # https://docs.kernel.org/admin-guide/sysrq.html
      # defaults: 16 ? / 64: enable signalling of process
      sysrq = 1;

      # 메모리 맵 파일의 최대 개수. (kernel 6.6 default: 65530) { NixOS 23.11 default 1048576 }
      # SteamOS/Fedora default
      "vm.max_map_count" = lib.mkOverride 999 2147483642;
    };
  };
}
