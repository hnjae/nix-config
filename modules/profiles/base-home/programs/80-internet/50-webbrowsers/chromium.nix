{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.base-home;
in
{
  config = lib.mkIf (cfg.isDesktop && pkgs.stdenv.isLinux) {
    # stateful.nodes = [
    #   {
    #     path = "${config.xdg.configHome}/chromium";
    #     mode = "700";
    #     type = "dir";
    #   }
    # ];

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
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
      # dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      extensions = [
        {
          id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; # ublock-origin-light
        }
      ];
    };
  };
}
