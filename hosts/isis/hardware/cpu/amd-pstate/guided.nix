# NOTE: konsole 두 탭, neovim 만 킬 경우 7W <2024-11-11>
{ ... }:
let
  cpuScalingGovernor = {
    # /sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors
    performance = "performance";
    schedutil = "schedutil";
  };
in
# lib.attrsets.optionalAttrs (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.4") # error: infinite recursion encountered
{
  boot.kernelParams = [
    "amd_pstate=guided"
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = cpuScalingGovernor.schedutil;
  };

  # https://linrunner.de/tlp/settings/processor.html
  services.tlp.settings = {
    # NOTE: guided 에서는 boost 를 끌 수 있다. <2024-11-11>
    # /sys/devices/system/cpu/cpufreq/boost
    # /sys/devices/system/cpu/cpufreq/policy0/boost
    CPU_BOOST_ON_BAT = 0;
    CPU_BOOST_ON_AC = 1;

    # CPU
    # run `tlp-stat -p` to determine availability on your hardware
    # CPU_SCALING_GOVERNOR_ON_AC = cpuScalingGovernor.schedutil;
    # CPU_SCALING_GOVERNOR_ON_BAT = cpuScalingGovernor.schedutil;

    # https://psref.lenovo.com/syspool/Sys/PDF/ThinkPad/ThinkPad_T14s_Gen_4_AMD/ThinkPad_T14s_Gen_4_AMD_Spec.pdf
    # https://www.amd.com/en/products/processors/laptop/ryzen/7000-series/amd-ryzen-7-7840u.html
    # /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
    # CPU_SCALING_MIN_FREQ_ON_AC = 400000;
    # CPU_SCALING_MAX_FREQ_ON_AC = 5100000;
    # CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
    # CPU_SCALING_MAX_FREQ_ON_BAT = 3300000;
  };
}
