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
  # boot.kernelPackages = pkgs.linuxPackages_6_12;

  ############
  # CPU
  ############
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amd_pstate=active" ]; # 2025-11-22: 왜 pstate 안먹냐..
  # services.auto-epp = {
  #   enable = true;
  #   settings.Settings.epp_state_for_BAT =
  # };

  # 8C16T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 8;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
