{ config, pkgs, ... }:
{
  # TODO: set aspm to l1 or l0s <2025-08-30>
  boot.kernelParams = [
    "nohibernate"

    # "pcie_aspm=off" # 일시적
    # "pcie_aspm.policy=powersupersave" # 이 옵션 Silconpower NVMe 에서 말썽.
    "pcie_aspm.policy=powersave"
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
    "kernel.nmi_watchdog" = 0;
    "vm.dirty_writeback_centisecs" = 1500; # follow powertop recommendation 2025-11-23
  };

  environment.defaultPackages = [
    pkgs.powertop # requires non-hardened kernel
    config.boot.kernelPackages.turbostat
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="scsi_host", ACTION=="add", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"

    SUBSYSTEM=="usb", ATTR{power/wakeup}="enabled"

    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{device/power/control}="auto"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 246 /dev/%k"
  '';

  # NOTE: 246 = 3 hours
}
