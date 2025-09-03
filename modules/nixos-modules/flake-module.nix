{ inputs, ... }:
{
  flake.nixosModules = {
    # services
    nix-gc-system-generations = import ./services/nix-gc-system-generations;
    nix-store-gc = import ./services/nix-store-gc;

    # programs
    lact = import ./programs/lact.nix;

    # system
    configure-impermanence = {
      imports = [
        inputs.impermanence.nixosModules.impermanence
        ./system/configure-impermanence.nix
      ];
    };

    rollback-zfs-root = import ./system/rollback-zfs-root.nix;
  };
}
