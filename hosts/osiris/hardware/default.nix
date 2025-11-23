{
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
    ./power.nix

    ./scanner.nix
  ];

  ############
  # CPU
  # AMD 5600X  (Zen 3)
  ############
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.kernelParams = [ "amd_pstate=active" ];
  # Get available governor: cpupower frequency-info
  powerManagement.cpuFreqGovernor = "powersave";
  # Current settings: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
  # Get available settings: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
  services.auto-epp = {
    enable = true;
    settings.Settings.epp_state_for_BAT = "balance_power";
    settings.Settings.epp_state_for_AC = "balance_power";
  };

  programs.ryzen-monitor-ng.enable = true;

  # Use zenpower instead of k10temp
  # https://github.com/AliEmreSenel/zenpower3
  hardware.cpu.amd.ryzen-smu.enable = true;
  boot.kernelModules = [
    "zenpower"
    "kvm-amd"
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.zenpower
  ];

  # 6C12T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 6;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
