{lib, ...}: {
  # pam services will be enabled by default <NixOS 23.11>
  services.fprintd = {
    enable = true;
  };

  # security.pam.services.login.fprintAuth = false;
  security.pam.services.sudo.fprintAuth = false;
  # security.pam.services.xlock.fprintAuth = false;
  # security.pam.services.vlock.fprintAuth = false;
  # security.pam.services.su.fprintAuth = false;
}
