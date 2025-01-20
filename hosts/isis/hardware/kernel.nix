{pkgs, ...}: {
  # https://www.kernel.org/
  # https://github.com/openzfs/zfs/releases/
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
