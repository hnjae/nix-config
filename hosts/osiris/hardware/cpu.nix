# CPU: AMD 5600X  (Zen 3)
{ config, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  # 6C12T
  nix.settings.max-jobs = 4;
  nix.settings.cores = 6;

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  programs.ryzen-monitor-ng.enable = true;

  ###################################
  # Use zenpower instead of k10temp #
  ###################################
  # https://github.com/AliEmreSenel/zenpower3
  boot.kernelModules = [
    "zenpower"
    "kvm-amd"
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.zenpower
  ];

  ############################
  # AMD CPU Power Management #
  ############################
  boot.kernelParams = [ "amd_pstate=active" ];

  # Get available governor: cpupower frequency-info
  powerManagement.cpuFreqGovernor = "powersave";

  # Current settings: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
  # Get available settings: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
  services.auto-epp = {
    enable = true;
    settings.Settings.epp_state_for_BAT = "performance";
    settings.Settings.epp_state_for_AC = "performance";
  };
}
