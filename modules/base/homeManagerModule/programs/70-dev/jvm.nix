{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  config = lib.mkIf baseHomeCfg.installDevPackages {
    home.packages = with pkgsUnstable; [
      jre17_minimal
      jdt-language-server

      kotlin-language-server
      kotlin-native
      ktlint
      ktfmt
      detekt
      kotlin
    ];
  };
}
