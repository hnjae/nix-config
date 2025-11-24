{
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./bootloader.nix
    ./disk-config.nix
    ./gpu.nix
    ./initrd.nix
    ./network.nix
    ./power.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_6_12_hardened;
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  ############
  # CPU (Zen1+)
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];

  # 8C16T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 8;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
