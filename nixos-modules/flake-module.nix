{
  imports = [
    ./autoaspm/flake-module.nix
    ./kde/flake-module.nix
  ];

  flake.nixosModules = {
    # services
    nixos-generation-gc = import ./nixos-generation-gc;
    nix-store-gc = import ./nix-store-gc;
  };
}
