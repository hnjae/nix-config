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
      # dictionaries = [ pkgs.hunspellDictsChromium.en_US ];
      extensions = [
        {
          id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; # ublock-origin-light
        }
      ];
    };
  };
}
