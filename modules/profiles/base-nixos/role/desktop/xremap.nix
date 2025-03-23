/*
  README:
    - Requires xremap to be imported
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
    };

    services.xremap.config.modmap = [
      {
        name = "Global";
        remap = {
          "CapsLock" = "BackSpace"; # xkboption 으로 설정하면, chromium+wayland 에서는 적용되지 않음

          # NOT Hangul_Hanja
          # NOTE: 이거 이름 어떻게 찾냐.. xkb 랑 일치하지 않음... <2025-03-23>
          # <https://github.com/xremap/xremap/discussions/356>
          # "Hanja" = "Alt_L"; # MS Keyboard;
          "Hanja" = "space"; # MS Keyboard;
        };
      }
    ];
  };
}
