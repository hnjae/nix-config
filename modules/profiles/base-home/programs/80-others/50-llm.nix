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
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    home.packages = lib.flatten [
      # FIX FOLLOWING: <NixOS 24.05>
      # MESA-LOADER: failed to open dri: /run/opengl-driver/lib/gbm/dri_gbm.so: cannot open shared object file: No such file or directory (search paths /run/opengl-driver/lib/gbm, suffix _gbm)
      # pkgsUnstable.jan
      # (pkgs.jan.overrideAttrs {
      #   inherit (pkgsUnstable.jan) version src;
      # })
      (import ./jan { inherit pkgs; })
    ];
  };
}
