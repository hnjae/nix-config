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
    ./brave-browser.nix
    ./firefox.nix
    ./google-chrome.nix
    ./opera.nix
    ./zen-browser.nix
  ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {

    home.packages = builtins.concatLists [
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
        path = "${config.xdg.configHome}/chromium";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
