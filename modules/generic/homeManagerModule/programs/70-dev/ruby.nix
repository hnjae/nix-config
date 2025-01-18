{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
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
