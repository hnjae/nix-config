{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config =
    lib.mkIf
    (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.is64bit) {
      default-app.browser = lib.mkForce "brave-browser";
      # default-app.fromApps = ["brave-browser"];

      home.packages = [
        (pkgs.brave.override {
          # NOTE: barve v1.62.165 에서는 --gtk-version=4 안먹음 + xwayand 에서
          # 한국어 입력 안됨 <2024-02-20>
          commandLineArgs = (
            builtins.concatStringsSep " " [
              "--ozone-platform-hint=auto"
              "--enable-features=UseOzonePlatform"
              "--enable-features=WaylandWindowDecorations"
              "--enable-wayland-ime"
              #   "--enable-features=VaapiVideoDecoder"
              #   "--enable-features=VaapiVideoEncoder"
              #   "--enable-features=VaapiIgnoreDriverChecks"
            ]
          );
        })
      ];

      stateful.cowNodes = [
        {
          path = "${config.xdg.configHome}/BraveSoftware";
          mode = "700";
          type = "dir";
        }
      ];
    };
}
