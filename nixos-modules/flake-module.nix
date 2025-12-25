{
  imports = [
    ./autoaspm/flake-module.nix
    ./kde/flake-module.nix
    ./nixos-gc/flake-module.nix
  ];

  flake.nixosModules = {
    # services
    nix-store-gc = import ./nix-store-gc;
  };
}
