{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop
    && pkgs.stdenv.isLinux
    && pkgs.stdenv.isx86_64
    && pkgs.config.allowUnfree) {
    # services.flatpak.packages = [
    #     "com.google.Chrome"
    # ];

    home.packages = [
      (pkgs.google-chrome.override {
        # NOTE: gtk-version=4 flag 안먹음 <2024-06-05>
        commandLineArgs =
          builtins.concatStringsSep
          " " [
            # "--enable-features=WaylandWindowDecorations"
            "--ozone-platform-hint=auto"
            "--enable-features=UseOzonePlatform"
            "--enable-wayland-ime"
            "--wayland-text-input-version=3"
            #     "--gtk-version=4"
            #     "--enable-features=VaapiVideoDecoder"
            #     "--enable-features=VaapiIgnoreDriverChecks"
          ];
      })
    ];

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/google-chrome";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.xdg.configHome}/google-chrome-beta";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.xdg.configHome}/google-chrome-unstable";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
