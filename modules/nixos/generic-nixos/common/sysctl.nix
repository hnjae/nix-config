{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  isDesktop = config.generic-nixos.role == "desktop";
in {
  # https://www.kernel.org/doc/Documentation/sysctl/vm.txt

  boot.kernel.sysctl = lib.attrsets.mergeAttrsList [
    (lib.attrsets.optionalAttrs isDesktop {
      # https://docs.kernel.org/admin-guide/sysrq.html
      "sysrq" = 1;
      # defaults: 16 ? / 64: enable signalling of process
      # NOTE: 강제 재부팅을 위해서는 1 이 되어야 함. <NixOS 24.05>
    })
    {
      # "kernel.sysrq" = 1;
      # kernel default: 3 (6.6)
      "vm.page-cluster" = mkOverride 999 2;

      # kernel 6.6 default: 100
      # from docs.kernel.org:
      # if the random IO against the swap device is on average 2x faster than IO
      # from the filesystem, swappiness should be 133 (x + 2x = 200, 2x = 133.33).
      "vm.swappiness" = mkOverride 999 1;
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

    # NOTE: https://rudd-o.com/linux-and-free-software/tales-from-responsivenessland-why-linux-feels-slow-and-how-to-fix-that
    # kernel default: 100 (6.6)
    {
      "vm.vfs_cache_pressure" = mkOverride 999 50;
    }

    # 메모리 맵 파일의 최대 개수. (kernel 6.6 default: 65530) { NixOS 23.11 default 1048576 }
    (lib.attrsets.optionalAttrs isDesktop {
      # SteamOS/Fedora default
      "vm.max_map_count" = lib.mkOverride 999 2147483642;
    })
  ];
}
