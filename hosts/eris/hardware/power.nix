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

  environment.defaultPackages = [
    pkgs.powertop # requires non-hardened kernel
    config.boot.kernelPackages.turbostat
  ];

  services.udev.extraRules = ''
    # Wake on lan
    ACTION=="add|change", SUBSYSTEM=="net", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"

    SUBSYSTEM=="scsi_host", ACTION=="add", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"

    # PCI Runtime Power Management
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"

    # SATA/SAS Block Devices Power Management
    # Does not work as expected
    # SUBSYSTEM=="block", KERNEL=="sd[a-z]", TEST=="power/control", ATTR{power/control}="auto"
    # WORKS:
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{device/power/control}="auto"

    # HDD Spindown and APM Settings
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 246 /dev/%k"

    ###########################
    # Individual Device Rules #
    ###########################
    # JetKVM
    # ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0104", ATTR{power/autosuspend}="-1", ATTR{power/control}="on", ATTR{power/wakeup}="enabled"

    ###############################
    # Generic IO USB Device Rules #
    ###############################
    # Disable wake on USB Mouse
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*Mouse*", ATTR{power/wakeup}="disabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    # Enable wake on USB Keyboard
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{product}=="*Keyboard*", ATTR{power/wakeup}="enabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    ###########################
    # Generic USB Device      #
    ###########################
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';

  # NOTE: 246 = 3 hours
}
