_: {
  # https://www.freedesktop.org/software/systemd/man/logind.conf.html
  # services.logind.lidSwitch = "suspend";
  # services.logind.lidSwitchExternalPower = "ignore";
  # services.logind.lidSwitchDocked = "ignore";
  services.logind.extraConfig = ''
    HandleHibernateKey=ignore
    HandlePowerKey=poweroff
    HandlePowerKeyLongPress=poweroff
  '';

  # See sleep.conf.d(5) man page for available options.
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    AllowHybridSleep=yes
  '';

  # See systemd-system.conf(5) man page for available options
  # NOTE: RuntimeWatchdogSec 은 기본으로 disabled 되어 있는데, s2idle 에서 이슈가 있어, 혹시나 해서 별도로 disable 해봄 <2024-12-13>
  systemd.extraConfig = ''
    RuntimeWatchdogSec=off
  '';

  # Extra config options for systemd-coredump. See coredump.conf(5) man page for available options.
  systemd.coredump.extraConfig = ''
    Compress=no
  '';
}
