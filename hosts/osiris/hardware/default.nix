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
    ./initrd.nix
    ./power.nix

    ./scanner.nix
  ];

  ############
  # CPU
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amd_pstate=passive" ];

  # 6C12T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 6;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
