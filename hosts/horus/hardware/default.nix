{ inputs, ... }:
{
  imports = [
    ./bootloader.nix
    ./containers-driver.nix
    ./cpu.nix
    ./fstab.nix
    ./gpu.nix
    ./kernel.nix

    # fstrim
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  networking = {
    hostName = "horus"; # Define your hostname.

    # for zfs. hexademical characters.
    # run `head -c4 /dev/urandom | od -A none -t x4`
    hostId = "78baec6a";
  };

  # Headless
  services.xserver.enable = false;

  # SCSI Link Power Management Policy
  powerManagement.scsiLinkPolicy = "med_power_with_dipm";

  # NOTE: ASPM is disabled in BIOS anyway <2023-10-05>
  boot.kernelParams = [
    # not working
    # "pcie_aspm.policy=powersupersave"

    # https://forums.developer.nvidia.com/t/nvme-ssd-drive-visible-in-lspci-but-not-visible-in-fdisk/107566
    # "pcie_aspm=off"
    "pcie_aspm.policy=powersave"
  ];
}
