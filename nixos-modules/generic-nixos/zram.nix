{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOverride;
in {
  # disable zswap and use zram
  zramSwap = {
    enable = mkOverride 999 true;
    # algorithm = "zstd";
    algorithm = mkOverride 999 "lz4";
    memoryPercent = mkOverride 999 90;
    memoryMax = mkOverride 999 null;
    priority = mkOverride 999 32766;
  };

  boot.kernelParams = lib.lists.optional config.zramSwap.enable "zswap.enabled=0";
}
