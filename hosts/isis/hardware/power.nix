{ pkgs, config, ... }:
{
  # USB 를 autosuspend 해, 마우스 사용에 애로사항이 있음.
  # Tunnable 한 값을 직접, module-parameter, udev, sysctl 를 이용해서 설정하자.
  # powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = true;

  boot.kernelParams = [
    # /sys/module/workqueue/parameters/power_efficient
    # "workqueue.power_efficient=true"
  ];

  environment.defaultPackages = [
    pkgs.powertop # requires non-hardened kernel
    config.boot.kernelPackages.turbostat
  ];

  powerManagement.scsiLinkPolicy = "med_power_with_dipm";

  services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 248 /dev/%k"

    # Disable wake on USB Mouse
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*Mouse*", ATTR{power/wakeup}="disabled"
  '';
  # NOTE: 248 = 4 hours
}
