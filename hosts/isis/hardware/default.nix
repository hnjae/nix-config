{ ... }:
{
  imports = [
    ./bootloader.nix
    ./cpu
    ./fstab.nix
    ./gpu.nix
    ./initrd.nix
    ./power.nix
    ./swap.nix
  ];
}
