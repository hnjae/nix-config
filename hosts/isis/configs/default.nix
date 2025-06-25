_: {
  imports = [
    ./systemd.nix
    ./pipewire.nix
    ./nameserver-encrypted.nix
  ];

  nix.settings.min-free = "343597383680"; # 20% of root zfs pool
}
