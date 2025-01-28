{ ... }:
{
  imports = [
    ./bootloader.nix
    ./containers-dirver.nix
    ./cpu
    ./fstab.nix
    ./gpu.nix
    ./kernel.nix
    ./suspend.nix
    ./swap.nix
  ];

  networking = {
    # run `head -c4 /dev/urandom | od -A none -t x4`
    hostId = "e177869e"; # for ZFS. hexadecimal characters.
  };

  boot.kernelParams = [
    # /sys/module/workqueue/parameters/power_efficient
    "workqueue.power_efficient=true"
  ];
}
