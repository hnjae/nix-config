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
        "--wayland-text-input-version=3"
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
      default-app.browser = lib.mkOptionDefault "brave-browser";

      home.packages = [package];

      xdg.mimeApps.associations.removed = let
        desktopName = "brave-browser.desktop";
        mimeTypes = [
          "application/pdf"
          "application/rdf+xml"
          "application/rss+xml"
          "image/gif"
          "image/jpeg"
          "image/png"
          "image/webp"
          "text/xml"
        ];
      in (
        builtins.listToAttrs (builtins.map (mimeType: {
            name = mimeType;
            value = desktopName;
          })
          mimeTypes)
      );

      stateful.nodes = [
        {
          path = "${config.xdg.configHome}/BraveSoftware";
          mode = "700";
          type = "dir";
        }
      ];
    };
}
