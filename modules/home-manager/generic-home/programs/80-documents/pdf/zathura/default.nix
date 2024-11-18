{
  config,
  pkgs,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (builtins) readFile;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    programs.zathura = {
      enable = genericHomeCfg.isDesktop;
      package = pkgs.zathura;
      extraConfig = builtins.concatStringsSep "\n" [
        (readFile ./resources/zathurarc)
        (lib.strings.optionalString (genericHomeCfg.base24.enable)
          (readFile (config.scheme {templateRepo = ./base24-zathura;})))
      ];
    };
    stateful.nodes = [
      {
        path = "${config.xdg.dataHome}/zathura";
        mode = "700";
        type = "dir";
      }
    ];
  };
}
