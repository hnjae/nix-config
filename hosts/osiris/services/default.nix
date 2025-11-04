{
  imports = [
    ./lact.nix
    ./ollama.nix
    ./systemd-mounts.nix
    ./systemd-resolved-encrypted.nix
    ./zfs-snapshot.nix
    ./zram.nix
  ];
}
