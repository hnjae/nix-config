{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 20;
    memoryMax = 1024 * 1024 * 1024 * 16;
    priority = 32766;
  };

  boot.kernelParams = [ "zswap.enabled=0" ];
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0; # https://old.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/

    # https://linuxblog.io/linux-performance-almost-always-add-swap-part2-zram/
    "vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 1;
    "vm.dirty_ratio" = 20;
    "vm.swappiness" = 10;
  };
}
