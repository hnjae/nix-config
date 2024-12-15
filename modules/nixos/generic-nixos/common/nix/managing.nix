{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  cfg = config.generic-nixos;
in {
  assertions = [
    {
      assertion = ! (config.services.nix-store-gc.enable && config.nix.gc.automatic);
      message = "Use only one of theses";
    }
  ];

  services.nix-gc-system-generations = {
    enable = config.services.nix-store-gc.enable;
    delThreshold =
      mkOverride 999
      {
        desktop = 3;
        vm = 1;
        hypervisor = 7;
      }
      ."${cfg.role}";
  };

  services.nix-store-gc = {
    enable = mkOverride 999 config.generic-nixos.role == "desktop";
  };

  nix.gc = {
    # run nix-collect-garbage
    automatic = mkOverride 999 false;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = "2h";
  };
}
