_: {
  imports = [
    ./ssh-host-keys
    ./sysctl.nix
    ./systemd.nix
    ./udev.nix
  ];

  nix.settings.min-free = "193273528320"; # 20% of root pool

  # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501/6
  # services.logrotate.checkConfig = false;
}
