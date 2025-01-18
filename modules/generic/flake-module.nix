_: {
  flake = {
    # Dependencies:
    # inputs.impermanence.nixosModules.home-manager.impermanence
    # inputs.nix-flatpak.homeManagerModules.nix-flatpak
    # inputs.base16.homeManagerModule
    # inputs.nix-index-database.hmModules.nix-index
    # inputs.nix-web-app.homeManagerModules.default
    homeManagerModules.generic-home = import ./homeManagerModule;

    # Dependencies:
    # self.nix-gc-system-generations
    # self.nix-store-gc
    # self.oci-container-auto-update
    # self.lact
    nixosModules.generic-nixos = import ./nixosModule;
  };
}
