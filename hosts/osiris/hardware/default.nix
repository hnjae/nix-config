{
  config,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-cpu-amd # includes `updateMicrocoder`
    ./bootloader.nix
    ./disk-config.nix
    ./gpu.nix
  ];

  ############
  # initrd
  ############

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  ############
  # CPU
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amd_pstate=passive" ];

  nix.settings.max-jobs = 6;
  nix.settings.cores = 6;
  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  ############
  # ZFS
  ############
  # run `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "f648c215"; # for ZFS. hexadecimal characters.
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.containers.storage.settings.storage.driver = "zfs";
  home-manager.sharedModules = [
    {
      /*
        NOTE: <2024-11-28>
          zfs is not supported in rooltless podman
          https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md
      */
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "overlay"
        '';
      };
    }
  ];
}
