_: {
  imports = [
    ./systemd.nix
    ./pipewire.nix
  ];

  nix.settings.min-free = "343597383680"; # 20% of root zfs pool
}
