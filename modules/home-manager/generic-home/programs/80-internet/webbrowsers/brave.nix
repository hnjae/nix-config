{
  pkgs,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;

  package = pkgs.brave.override {
    # NOTE: barve v1.62.165 에서는 --gtk-version=4 안먹음 + xwayand 에서
    # 한국어 입력 안됨 <2024-02-20>
    commandLineArgs = (
      builtins.concatStringsSep " " [
        "--ozone-platform-hint=auto"
        "--enable-features=UseOzonePlatform"
        "--enable-wayland-ime"
        # "--enable-features=WaylandWindowDecorations"
        #   "--enable-features=VaapiVideoDecoder"
        #   "--enable-features=VaapiVideoEncoder"
        #   "--enable-features=VaapiIgnoreDriverChecks"
      ]
    );
  };
in {
  config =
    lib.mkIf
    (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.is64bit) {
      default-app.browser = lib.mkForce "brave-browser";
      # default-app.fromApps = ["brave-browser"];

      home.packages = [package];
      xdg.mimeApps.associations.removed = {
        "image/webp" = "brave-browser.desktop";
        "image/png" = "brave-browser.desktop";
        "image/jpeg" = "brave-browser.desktop";
        "image/gif" = "brave-browser.desktop";
      };

      # xdg.desktopEntries."webapp-apple-music" = {
      #   name = "Apple Music";
      #   genericName = "Music Streaming Service";
      #   terminal = false;
      #   exec = "${package}/bin/brave --profile-directory=Default --app-id=apple-music";
      #   icon = "apple-music";
      #   settings = {
      #     StartupWMClass = "crx_apple-music";
      #   };
      # };

      stateful.cowNodes = [
        {
          path = "${config.xdg.configHome}/BraveSoftware";
          mode = "700";
          type = "dir";
        }
      ];
    };
}
