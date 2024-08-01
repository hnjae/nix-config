{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config =
    lib.mkIf
    (genericHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.is64bit) {
      home.packages = [
        (pkgs.opera.overrideAttrs
          (_: {inherit (pkgsUnstable.opera) version src;}))
      ];
    };
}
