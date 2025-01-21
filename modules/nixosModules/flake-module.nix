{...}: {
  flake.nixosModules = rec {
    # services
    nix-gc-system-generations = import ./services/nix-gc-system-generations;
    nix-store-gc = import ./services/nix-store-gc;
    oci-container-auto-update = import ./services/oci-container-auto-update;
    syncthing-for-desktop = import ./services/syncthing-for-desktop;

    # programs
    lact = import ./programs/lact.nix;

    # system
    # Dependencies: - impermanence.nixosModules.impermanence
    configure-impermanence = import ./system/configure-impermanence.nix;
    rollback-zfs-root = import ./system/rollback-zfs-root.nix;
  };
}
