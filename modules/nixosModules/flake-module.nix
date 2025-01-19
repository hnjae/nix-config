{...}: {
  flake.nixosModules = rec {
    # services
    nix-gc-system-generations = import ./services/nix-gc-system-generations;
    nix-store-gc = import ./services/nix-store-gc;
    oci-container-auto-update = import ./services/oci-container-auto-update;

    # programs
    lact = import ./programs/lact.nix;
  };
}
