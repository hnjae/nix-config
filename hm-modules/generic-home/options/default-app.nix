{
  pkgs,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {default-app.enable = genericHomeCfg.isDesktop && pkgs.stdenv.isLinux;}
