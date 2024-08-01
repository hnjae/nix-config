{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.installDevPackages {
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
