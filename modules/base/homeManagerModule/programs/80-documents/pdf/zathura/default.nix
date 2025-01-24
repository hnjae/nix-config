{
  config,
  pkgs,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (builtins) readFile;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    programs.zathura = {
      enable = baseHomeCfg.isDesktop;
      package = pkgs.zathura;
      extraConfig = builtins.concatStringsSep "\n" [
        (readFile ./resources/zathurarc)
        (lib.strings.optionalString (baseHomeCfg.base24.enable) (
          readFile (config.scheme { templateRepo = ./base24-zathura; })
        ))
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
