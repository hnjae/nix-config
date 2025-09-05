{ config, ... }:
let
  isDesktop = config.base-nixos.role == "desktop";

  # default: 90
  timeoutStart = if isDesktop then "30" else "90";
  timeoutStop = if isDesktop then "30" else "180";
in
{
  # NOTE: man 5 systemd.conf.d <2023-10-06>
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=${timeoutStart}s
    DefaultTimeoutStopSec=${timeoutStop}s
  '';

  # man 5 systemd-user.conf
  # https://www.freedesktop.org/software/systemd/man/latest/systemd-user.conf.html
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=${timeoutStop}s
  '';
}
