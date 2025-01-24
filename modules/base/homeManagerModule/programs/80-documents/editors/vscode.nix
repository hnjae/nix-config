{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.config.allowUnfree) {
    home.packages = [pkgsUnstable.vscode-fhs];

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/Code";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.home.homeDirectory}/.vscode";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
