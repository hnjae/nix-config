{
  pkgs,
  config,
  ...
}: let
  baseHomeCfg = config.base-home;
in {default-app.enable = baseHomeCfg.isDesktop && pkgs.stdenv.isLinux;}
