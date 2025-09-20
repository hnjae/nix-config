{ inputs, ... }:
{
  flake.nixosModules = {
    # services
    nixos-generation-gc = import ./services/nixos-generation-gc;
    nix-store-gc = import ./services/nix-store-gc;

    # programs
    lact = import ./programs/lact.nix;
  };
}
