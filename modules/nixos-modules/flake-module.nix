{ inputs, ... }:
{
  flake.nixosModules = {
    # services
    nix-gc-system-generations = import ./services/nix-gc-system-generations;
    nix-store-gc = import ./services/nix-store-gc;

    # programs
    lact = import ./programs/lact.nix;
  };
}
