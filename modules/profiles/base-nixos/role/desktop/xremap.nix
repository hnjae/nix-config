/*
  README:
    - <https://github.com/xremap/xremap/blob/master/README.md>
    - Requires xremap to be imported
    - run following to get device names
      ```console
      nix run nixpkgs#libinput -- list-devices
      # or
      nix run nixpkgs#evtest
      ```
    - ```console
      nix run github:xremap/nix-flake -- --version
      ```
*/
{
  config,
  lib,
  ...
}:
let
  cfg = config.base-nixos;
in
{
  config = lib.mkIf (cfg.role == "desktop") {
    services.xremap = {
      enable = true;
      serviceMode = "user";
      userName = "hnjae";
      withGnome = config.services.xserver.desktopManager.gnome.enable;
      watch = true;
      mouse = true;
    };
    environment.systemPackages = [ config.services.xremap.package ];

    services.xremap.config.modmap = [
      {
        name = "Global";
        remap = {
          "CapsLock" = "BackSpace"; # xkboption 으로 설정하면, chromium+wayland 에서는 적용되지 않음
        };
      }
      {
        name = "ms-designer-compact-keyboard";
        remap = {
          # NOT Hangul_Hanja
          # NOTE: 이거 이름 어떻게 찾냐.. xkb 랑 일치하지 않음... <2025-03-23>
          # <https://github.com/xremap/xremap/discussions/356>
          # "Hanja" = "Alt_L"; # MS Keyboard;
          "Hanja" = "space"; # MS Keyboard;
        };
        device.only = [ "Designer Compact Keyboard" ];
      }
      # NOTE: gnome 이 디바이스별 설정을 지원하지 않아 xremap 단에서 처리. <2025-03-30>
      {
        name = "left-handed-mouse";
        remap = {
          "BTN_LEFT" = "BTN_RIGHT";
          "BTN_RIGHT" = "BTN_LEFT";
        };
        device.only = [
          "Lenovo Bluetooth Mouse"
          "M5 Nano Mouse BT Mouse" # 한성 마우스
        ];
      }
    ];
  };
}
