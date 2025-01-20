/*
NOTE:

# NOTE: konsole 두 탭, neovim 만 킬 경우 7W <2024-11-11>

run
  sudo tlp-stat -p
  sudo cpupower frequency-info
  cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
*/
{
  # config,
  # lib,
  ...
}: let
  # kver = config.boot.kernelPackages.kernel.version;
  cpuScalingGovernor = {
    performance = "performance";
    powersave = "powersave";
  };
in {
  imports = [
    ./systemd-set-epp.nix
  ];

  boot.kernelParams = [
    "amd_pstate=active"
  ];

  powerManagement = {
    enable = true;
    # NOTE: 는 아래는 policy 에만 적용 (cpupower frequency-info 로 확인) <2024-11-11>
    # 아래는  /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 를 바꿈. cpuinfo_max_freq, amd_pstate_max_freq 를 바꾸지는 않는다.
    # cpufreq = {
    #   max = builtins.floor (3.3 * 1000 * 1000);
    # };
    cpuFreqGovernor = cpuScalingGovernor.powersave;
  };

  services.tlp.settings = {
    # NOTE: 아래 적용 안됨  <2024-11-11>
    # NOTE: 아예 active 는 boost 끄는 기능이 없는 것 같은데? <2024-11-11>
    # (cpupower frequency-info 에서 적용되질 않음)
    # CPU_BOOST_ON_BAT = 0;
    # CPU_BOOST_ON_AC = 0;

    # CPU
    # run `tlp-stat -p` to determine availability on your hardware
    # CPU_SCALING_GOVERNOR_ON_AC = cpuScalingGovernor.powersave;
    # CPU_SCALING_GOVERNOR_ON_BAT = cpuScalingGovernor.powersave;

    # NOTE: EPP 배터리 충전 여부에 따라 변하는 것 적용 안됨 <NixOS 24.11>
    # CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    # CPU_ENERGY_PERF_POLICY_ON_BAT = "default";
  };
}
