_: {
  # https://www.freedesktop.org/software/systemd/man/logind.conf.html
  services.logind.extraConfig = ''
    HandlePowerKey=poweroff
    HandlePowerKeyLongPress=poweroff
    HandleRebootKey=poweroff
    HandleRebootKeyLongPress=poweroff
    HandleSuspendKey=poweroff
    HandleSuspendKeyLongPress=poweroff
    HandleHibernateKey=poweroff
    HandleHibernateKeyLongPress=poweroff

    PowerKeyIgnoreInhibited=yes
    SuspendKeyIgnoreInhibited=yes
    HibernateKeyIgnoreInhibited=yes
    RebootKeyIgnoreInhibited=yes
  '';

  #  See sleep.conf.d(5) man page for available options.
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
}
