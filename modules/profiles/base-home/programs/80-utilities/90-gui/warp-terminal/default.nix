{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.config.allowUnfree) {
    home.packages = [ pkgsUnstable.warp-terminal ];
    default-app.fromApps = [ "dev.warp.Warp" ];
  };
}
