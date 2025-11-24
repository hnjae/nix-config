{ config, pkgs, ... }:
{
  boot.kernelParams = [
    "nohibernate"
  ];

  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
    "kernel.nmi_watchdog" = 0;
    "vm.dirty_writeback_centisecs" = 1500; # follow powertop recommendation 2025-11-23
  };

  environment.defaultPackages = [
    config.boot.kernelPackages.turbostat
  ];

  powerManagement.scsiLinkPolicy = "med_power_with_dipm";
  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"

    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 248 /dev/%k"
  '';

  # NOTE: 248 = 4 hours
}
