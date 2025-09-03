{
  # disable zswap and use zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    memoryMax = 1024 * 1024 * 1024 * 16;
    priority = 32766;
  };

  boot.kernelParams = [ "zswap.enabled=0" ];
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0; # https://old.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
    "vm.swappiness" = 50;
  };
}
