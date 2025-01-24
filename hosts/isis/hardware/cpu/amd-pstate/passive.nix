# 7W konsole 두 탭 + nvim (2024-11-11)
{
  # config,
  # lib,
  ...
}:
let
  # kver = config.boot.kernelPackages.kernel.version;
  cpuScalingGovernor = {
    performance = "performance";
    schedutil = "schedutil";
  };
in
{
  boot.kernelParams = [
    "amd_pstate=passive"
  ];

  # `sudo cpupower frequency-info`
  # /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
  # https://psref.lenovo.com/syspool/Sys/PDF/ThinkPad/ThinkPad_T14s_Gen_4_AMD/ThinkPad_T14s_Gen_4_AMD_Spec.pdf
  # https://www.amd.com/en/products/processors/laptop/ryzen/7000-series/amd-ryzen-7-7840u.html
  # /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
  # AMD PSTATE Lowest Non-linear Performance: 42. Lowest Non-linear Frequency: 1.10 GHz.

  powerManagement = {
    enable = true;

    # NOTE:  <2025-01-05>
    # Failed to find module 'cpufreq_schedutil'
    # 아래를 끄면, 위가 해결이 되나?
    # cpuFreqGovernor = cpuScalingGovernor.schedutil;
  };
  services.tlp.settings = {
    CPU_BOOST_ON_BAT = 0;
    CPU_BOOST_ON_AC = 1;

    # https://linrunner.de/tlp/settings/processor.html
    # CPU
    # run `tlp-stat -p` to determine availability on your hardware
    # CPU_SCALING_GOVERNOR_ON_AC = cpuScalingGovernor.schedutil;
    # CPU_SCALING_GOVERNOR_ON_BAT = cpuScalingGovernor.schedutil;
  };
}
