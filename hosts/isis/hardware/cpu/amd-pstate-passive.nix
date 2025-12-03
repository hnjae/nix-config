# 7W konsole 두 탭 + nvim (2024-11-11)
{
  config,
  lib,
  pkgs,
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

  # services.tlp.settings = {
  #   CPU_BOOST_ON_BAT = 0;
  #   CPU_BOOST_ON_AC = 1;
  #
  #   # https://linrunner.de/tlp/settings/processor.html
  #   # run `tlp-stat -p` to determine availability on your hardware
  #   CPU_SCALING_GOVERNOR_ON_AC = cpuScalingGovernor.schedutil;
  #   CPU_SCALING_GOVERNOR_ON_BAT = cpuScalingGovernor.schedutil;
  #
  #   # PLATFORM_PROFILE_ON_AC = "performance";
  #   PLATFORM_PROFILE_ON_AC = "balanced";
  #   PLATFORM_PROFILE_ON_BAT = "balanced";
  # };

  environment.systemPackages = [
    (lib.customisation.overrideDerivation
      # NOTE: 외부 배터리로 가동 중일때 사용할 스크립트
      (pkgs.writeShellApplication {
        name = "set-bat-mode";

        runtimeInputs = [
          config.boot.kernelPackages.cpupower
          pkgs.tlp
        ];

        text = ''
          bat_threshold_clamp() {
            val="$1"
            min="$2"
            max="$3"

            if [ "$val" -gt "$max" ]; then
              echo "$max"
            elif [ "$val" -lt "$min" ]; then
              echo "$min"
            else
              echo "$val"
            fi
          }

          echo "[INFO] Disabling CPU Boost" >&2
          echo 0 >"/sys/devices/system/cpu/cpufreq/boost"

          echo "[INFO] Setting ACPI platform profile to balanced" >&2
          echo "balanced" >"/sys/firmware/acpi/platform_profile"

          echo "[INFO] Setting CPU frequency governor to schedutil" >&2
          cpupower frequency-set -g schedutil

          CHARGE_CONTROL_END_THRESHOLD_PATH="/sys/class/power_supply/BAT0/charge_control_end_threshold"
          CHARGE_CONTROL_START_THRESHOLD_PATH="/sys/class/power_supply/BAT0/charge_control_start_threshold"
          bat_capacity="$(cat "/sys/class/power_supply/BAT0/capacity")"
          cur_end_threshold="$(cat "$CHARGE_CONTROL_END_THRESHOLD_PATH")"

          end_threshold=$((bat_capacity -1))
          end_threshold="$(bat_threshold_clamp "$end_threshold" 20 100)"

          start_threshold=$((end_threshold -1))
          start_threshold="$(bat_threshold_clamp "$start_threshold" 0 "$start_threshold")"

          echo "[INFO] STOP CHARGING / Setting charge end threshold to $end_threshold" >&2

          if [ "$cur_end_threshold" -gt "$end_threshold" ]; then
            echo "$start_threshold" >"$CHARGE_CONTROL_START_THRESHOLD_PATH"
            echo "$end_threshold" >"$CHARGE_CONTROL_END_THRESHOLD_PATH"
          else
            echo "$end_threshold" >"$CHARGE_CONTROL_END_THRESHOLD_PATH"
            echo "$start_threshold" >"$CHARGE_CONTROL_START_THRESHOLD_PATH"
          fi

          echo "------------------" >&2
          tlp-stat -p
        '';
      })
      (_: {
        preferLocalBuild = true;
      })
    )

  ];
}
