{

  #  See sleep.conf.d(5) man page for available options.
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  boot.kernel.sysctl = {
    # https://wiki.archlinux.org/title/Power_management#Disabling_NMI_watchdog
    "kernel.nmi_watchdog" = 0;
  };
}
