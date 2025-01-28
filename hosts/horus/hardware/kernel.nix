{
  pkgs,
  lib,
  ...
}:
{
  # Kernel
  # https://www.kernel.org/category/releases.html
  # NOTE: Use LTS Kernel Only <2024-01-09>

  # Notes:
  # pkgs.linuxPackages_6_5_hardened 는 부팅 이슈가 있었음
  # https://www.kernel.org/category/releases.html

  # boot.kernelPackages = pkgs.linuxPackages_6_1_hardened; # NixOS 24.05 에서 잘 작동됨
  # boot.kernelPackages = pkgs.linuxPackages_6_6_hardened; # NOTE: NixOS 24.05 에서 부팅 안됨.
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.supportedFilesystems = {
    zfs = lib.mkForce true;
  };

  boot.kernelParams = [
    # https://docs.redhat.com/ko/documentation/red_hat_virtualization/4.0/html/installation_guide/sect-Hypervisor_Requirements#CPU_Requirements
    # https://www.kernel.org/doc/html/v6.6/admin-guide/kernel-parameters.html
    # "amd_iommu=off"
    # "iommu=off"
  ];
}
