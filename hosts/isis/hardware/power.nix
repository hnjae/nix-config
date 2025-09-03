{

  boot.kernelParams = [
    # /sys/module/workqueue/parameters/power_efficient
    "workqueue.power_efficient=true"
  ];
  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
    "kernel.nmi_watchdog" = 0;
  };
}
