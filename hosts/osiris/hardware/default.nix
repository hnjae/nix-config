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
}
