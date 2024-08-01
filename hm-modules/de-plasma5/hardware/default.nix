{...}: {
  imports = [
    ./kcminputs
    ./input-devices.nix
    ./virtual-keyboard.nix
    ./power-management.nix
    ./display-and-monitor.nix
  ];

  # Hardware - Audio
  programs.plasma.configFile."plasmaparc" = {
    "General"."VolumeStep".value = 4;
  };
}
