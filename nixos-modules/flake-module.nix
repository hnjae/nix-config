{self, ...}: {
  flake = {
    nixosModules = {
      generic-nixos = import ./generic-nixos;

      de-plasma6 = import ./de-plasma6;

      # my services
      nix-gc = import ./services/nix-gc;
      oci-container-auto-update = import ./services/oci-container-auto-update;

      #
      lact = import ./programs/lact.nix;

      default = {
        imports = [
          self.nixosModules.generic-nixos
          self.nixosModules.nix-gc
          self.nixosModules.oci-container-auto-update
          self.nixosModules.lact
        ];
      };
    };
  };
}
