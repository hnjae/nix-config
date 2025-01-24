{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./google-chrome.nix
    ./opera.nix
  ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    default-app.browser = "app.zen_browser.zen";

    services.flatpak.packages = [
      "app.zen_browser.zen"
    ];

    home.packages = builtins.concatLists [
      (lib.lists.optionals (pkgs.stdenv.isLinux) [
        pkgs.librewolf
        pkgs.firefox-devedition-bin
      ])

      (lib.lists.optional (pkgs.stdenv.isLinux) (
        let
          flags = builtins.concatStringsSep " " [
            # enable Wayland
            "--ozone-platform-hint=auto"
            "--enable-features=UseOzonePlatform"
            # enable text-input-v3
            "--enable-wayland-ime"
            "--wayland-text-input-version=3"
            # enable VA-API
            "--enable-features=AcceleratedVideoDecodeLinuxGL"
            "--enable-features=VaapiIgnoreDriverChecks"
          ];
        in
        (pkgs.writeScriptBin "chromium" ''
          #!${pkgs.dash}/bin/dash
          ${pkgs.ungoogled-chromium}/bin/chromium ${flags} "$@"
        '')
      ))
    ];

    stateful.nodes = [
      {
        path = "${config.home.homeDirectory}/.librewolf";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.home.homeDirectory}/.mozilla";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.xdg.configHome}/chromium";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
