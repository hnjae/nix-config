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
    ./power.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_12_hardened;

  ############
  # CPU
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    # https://wiki.gentoo.org/wiki/Power_management/Processor/en
    # "amd_pstate=passive"
    "amd_pstate.shared_mem=1" # zen-2
  ];

  # 6C12T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 6;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
