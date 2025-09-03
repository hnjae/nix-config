{ lib, ... }:
let
  inherit (lib) mkOverride;
in
{
  # https://www.kernel.org/doc/Documentation/sysctl/vm.txt

  boot.kernel.sysctl = lib.attrsets.mergeAttrsList [
    {
      # kernel default: 3 (6.6)
      "vm.page-cluster" = mkOverride 999 1; # for nvme
      "vm.swappiness" = mkOverride 999 60;
    }
    {
      # "vm.watermark_boost_factor" = 0;
      # "vm.watermark_scale_factor" = 125;

      # Contains, as a percentage of total available memory that contains free pages and reclaimable pages, the number of pages at which a process which is generating disk writes will itself start writing out dirty data.
      # The total available memory is not equal to total system memory.
      # "vm.dirty_ratio" = lib.mkDefault 10;

      # Contains, as a percentage of total available memory that contains free pages and reclaimable pages, the number of pages at which the background kernel flusher threads will start writing out dirty data.
      # The total available memory is not equal to total system memory.
      # "vm.dirty_background_ratio" = lib.mkDefault 5;
    }
    {
      # NOTE: https://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
      # kernel default: 100 (6.6)
      "vm.vfs_cache_pressure" = mkOverride 999 50;
    }
  ];
}
