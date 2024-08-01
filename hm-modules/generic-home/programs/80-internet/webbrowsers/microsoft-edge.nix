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
    (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64) {
      stateful.cowNodes = [
        {
          path = "${config.xdg.configHome}/microsoft-edge";
          mode = "700";
          type = "dir";
        }
        {
          path = "${config.xdg.configHome}/microsoft-edge-dev";
          mode = "700";
          type = "dir";
        }
      ];

      home.packages = [
        (pkgs.microsoft-edge.override {
          # NOTE: gtk-version=4 flag 안먹음 <2024-06-05>
          # commandLineArgs =
          #   builtins.concatStringsSep
          #   " " [
          #     # "--ozone-platform-hint=auto"
          #     # "--enable-features=UseOzonePlatform"
          #     # "--enable-wayland-ime"
          #     #     "--enable-features=WaylandWindowDecorations"
          #     #     "--gtk-version=4"
          #   ];
        })
      ];
    };
}
