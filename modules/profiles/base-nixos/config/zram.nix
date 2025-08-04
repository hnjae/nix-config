{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOverride;
in
{
  # disable zswap and use zram
  zramSwap = {
    enable = mkOverride 999 true;
    algorithm = mkOverride 999 "lz4";
    memoryPercent = mkOverride 999 50;
    memoryMax = mkOverride 999 (1024 * 1024 * 1024 * 12);
    priority = mkOverride 999 32766;
  };

  boot.kernelParams = lib.lists.optional config.zramSwap.enable "zswap.enabled=0";

  # zram tuning
  # https://segmentfault.com/a/1190000041578292/en
  # https://github.com/pop-os/default-settings/pull/163
  # https://old.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
  boot.kernel.sysctl = lib.mkIf config.zramSwap.enable {
    # kernel default: 3 (6.6)
    "vm.page-cluster" = mkOverride 100 0;

    # kernel 6.6 default: 100
    # from docs.kernel.org:
    # if the random IO against the swap device is on average 2x faster than IO
    # from the filesystem, swappiness should be 133 (x + 2x = 200, 2x = 133.33).
    # 180: PopOS defaults
    "vm.swappiness" = mkOverride 100 100;
  };
}
