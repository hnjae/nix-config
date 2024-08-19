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

  # zram tuning
  # https://segmentfault.com/a/1190000041578292/en
  # https://github.com/pop-os/default-settings/pull/163
  # https://old.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
  boot.kernel.sysctl = lib.mkIf config.zramSwap.enable {
    # kernel default: 3 (6.6)
    "vm.page-cluster" = mkOverride 100 2;
    "vm.swappiness" = mkOverride 100 1;
  };
}
