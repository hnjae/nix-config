_: {
  imports = [
    ./sysctl.nix
    ./systemd.nix
    ./udev.nix
  ];

  security.sudo-rs.wheelNeedsPassword = false;

  # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501/6
  services.logrotate.checkConfig = false;
}
