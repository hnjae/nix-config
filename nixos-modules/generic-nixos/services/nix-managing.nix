{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  inherit (config.generic-nixos) isDesktop;
in {
  services.nix-gc-system-generations = {
    enable = mkOverride 999 true;
    delThreshold = mkOverride 999 (
      if isDesktop
      then 3
      else 7
    );
    onCalendar = mkOverride 999 "daily";
  };

  services.nix-store-gc = {
    enable = mkOverride 999 (
      if isDesktop
      then true
      else true
    );
    onCalendar = mkOverride 999 "Tue,Fri";
  };

  nix.gc = {
    # run nix-collect-garbage
    automatic = mkOverride 999 false;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = "24h";
  };
}
