{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [go];
  };
}
