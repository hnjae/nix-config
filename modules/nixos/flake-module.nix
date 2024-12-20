{...}: {
  flake.nixosModules = rec {
    generic-nixos = import ./generic-nixos;

    # services
    nix-gc-system-generations = import ./services/nix-gc-system-generations;
    nix-store-gc = import ./services/nix-store-gc;
    oci-container-auto-update = import ./services/oci-container-auto-update;

    # programs
    lact = import ./programs/lact.nix;

    #
    gnome = import ./desktop-environments/gnome;
    plasma = import ./desktop-environments/plasma;

    default = {
      imports = [
        generic-nixos

        nix-gc-system-generations
        nix-store-gc
        oci-container-auto-update

        lact
      ];
    };
  };
}
