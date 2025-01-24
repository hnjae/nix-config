# https://wiki.archlinux.org/title/CPU_frequency_scaling#Intel_performance_and_energy_bias_hint
# amd-pstate 가 active 일때만 사용 가능.
# NOTE: cpuScalingGovernor 가 powersave 일 경에만 EPP 가 적용 가능 <Kernel 6.8.6; amd-pstate-epp>
{ pkgs, ... }:
let
  cpuEnergyPerfPolicy = {
    performance = "performance";
    balancePerformance = "balance_performance";
    # default = "default";
    balancePower = "balancePower";
    power = "power";
  };

  path = ''/sys/devices/system/cpu/cpu''${j}/cpufreq/energy_performance_preference'';
  # balancePower 뭔가 반응이 미묘하게 느려..
  eppPreferences = cpuEnergyPerfPolicy.balance_performance;
  numCPU = "16";

  serviceName = "set-epp";
  description = "Set EPP policy";
in
{
  systemd.services.${serviceName} = {
    inherit description;

    serviceConfig = {
      Type = "oneshot";
      # ExecStart = "/etc/${configPath}/${scriptName}";
      ExecStart = pkgs.writeScript serviceName ''
        #!${pkgs.dash}/bin/dash

        j=0
        while [ "$j" -lt ${numCPU} ]; do
          [ -f "${path}" ] && echo "${eppPreferences}" > "${path}" || echo "ERROR: ${path} does not exists"
          j=$(( j + 1 ))
        done
      '';
    };

    wantedBy = [ "multi-user.target" ];
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/cpu-freq.nix
    after = [ "systemd-modules-load.service" ];
  };
}
