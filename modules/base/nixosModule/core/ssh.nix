{ lib, ... }:
let
  inherit (lib) mkOverride;
in
{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = mkOverride 999 true;
    settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      # PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = mkOverride 999 false;
      # UseDns = mkOverride 999 true;
    };
  };
}
