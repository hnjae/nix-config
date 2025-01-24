{config, ...}: let
  isDesktop = config.base-nixos.role == "desktop";

  timeoutPeriod =
    if isDesktop
    then "20"
    else "90"; # default
in {
  # NOTE: man 5 systemd.conf.d <2023-10-06>
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=${timeoutPeriod}s
    DefaultTimeoutStopSec=${timeoutPeriod}s
  '';

  # man 5 systemd-user.conf
  # https://www.freedesktop.org/software/systemd/man/latest/systemd-user.conf.html
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=${timeoutPeriod}s
  '';
}
