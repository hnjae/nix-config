{
  config,
  lib,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = with pkgs; [ruby];

    stateful.nodes = [
      {
        path = "${config.xdg.dataHome}/gem";
        mode = "755";
        type = "dir";
      }
    ];
  };
}
