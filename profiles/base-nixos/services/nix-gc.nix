{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOverride;
  cfg = config.base-nixos;
in
{
  assertions = [
    {
      assertion = !(config.my.services.nix-store-gc.enable && config.nix.gc.automatic);
      message = "Use only one of theses";
    }
  ];

  my.services.nixos-gc = {
    # enable = config.services.nix-store-gc.enable;
    enable = lib.mkForce true;
    keepDays =
      mkOverride 999
        {
          desktop = 7;
          none = 14;
        }
        ."${cfg.role}";
  };

  my.services.nix-store-gc = {
    enable = mkOverride 999 true;
  };

  nix.gc = {
    # run nix-collect-garbage
    automatic = mkOverride 999 false;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = "2h";
  };
}
