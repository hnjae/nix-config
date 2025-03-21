/*
  NOTE:
    flatpak version of cider-2 does not register icon <2025-03-21>
*/
{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome) {
    home.packages = [
      (pkgsUnstable.cider-2.override {
        inherit (pkgs)
          appimageTools
          lib
          makeWrapper
          requireFile
          ;
      })
    ];

    # xdg.dataFile."applications/cider-2.desktop" = {
    #   enable = true;
    #   text = ''
    #     [Desktop Entry]
    #     Name=Cider
    #     Exec=cider-2 --ozone-platform-hint=auto --enable-features=UseOzonePlatform --enable-wayland-ime --wayland-text-input-version=3 %U
    #     Terminal=false
    #     Type=Application
    #     Icon=cider
    #     StartupWMClass=Cider
    #     X-AppImage-Version=1.0.0
    #     StartupNotify=false
    #     Encoding=UTF-8
    #     MimeType=x-scheme-handler/cider;
    #     Comment=A cross-platform Apple Music experience built on Vue.js and written from the ground up with performance in mind.
    #     Categories=AudioVideo;
    #   '';
    # };

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/sh.cider.electron";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
