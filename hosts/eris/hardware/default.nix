{
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./initrd.nix
    ./bootloader.nix
    ./disk-config.nix
    ./cpu.nix
    ./network.nix

    ./ha-efi.nix
    ./gpu.nix
    ./power.nix
  ];

  # boot.kernelPackages = pkgs.linuxPackages_6_12_hardened;
  boot.kernelPackages = pkgs.linuxPackages_6_18;
}
