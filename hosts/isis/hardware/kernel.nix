{ pkgs, ... }:
{
  # https://www.kernel.org/category/releases.html
  # https://github.com/openzfs/zfs/releases/
  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
