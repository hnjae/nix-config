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
    ./initrd.nix
    ./network.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12_hardened;

  ############
  # CPU
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amd_pstate=passive" ];

  nix.settings.max-jobs = 6;
  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
