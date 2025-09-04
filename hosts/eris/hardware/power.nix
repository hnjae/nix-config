{ pkgs, config, ... }:
{
  # TODO: set aspm to l1 or l0s <2025-08-30>
  boot.kernelParams = [
    "nohibernate"
    # "pcie_aspm=off" # 일시적
    # "pcie_aspm.policy=powersupersave" # 이 옵션 Silconpower NVMe 에서 말썽.
    "pcie_aspm.policy=powersave"
  ];

  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
    "kernel.nmi_watchdog" = 0;
  };

  environment.defaultPackages = with pkgs; [
    ryzen-monitor-ng
    powertop
  ];

  # load module at stage2
  boot.kernelModules = [
    "ryzen-smu"
  ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    ryzen-smu
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="scsi_host", ACTION=="add", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';
}
