{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.config.allowUnfree) {
    home.packages = [pkgsUnstable.warp-terminal];
    default-app.fromApps = ["dev.warp.Warp"];
  };
}
