{lib, ...}: {
  # <NixOS 23.06>: weekly run fstrim
  # NOTE: 설정에 Persistent=true 존재 <NixOS 23.11>
  # NOTE: use btrfs's discard=async in fstab instead <2024-01-15>
  services.fstrim.enable = lib.mkOverride 999 false;
}
