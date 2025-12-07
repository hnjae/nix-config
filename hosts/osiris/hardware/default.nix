{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./bootloader.nix
    ./cpu.nix
    ./disk-config.nix
    ./gpu.nix
    ./initrd.nix

    ./power.nix

    ./scanner.nix
  ];
}
