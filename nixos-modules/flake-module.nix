{self, ...}: {
  flake = {
    nixosModules = {
      generic-nixos = import ./generic-nixos;

      de-plasma6 = import ./de-plasma6;
      ds-gnome = import ./de-gnome;
      ds-sway = import ./de-sway;
      ds-pantheon = import ./de-pantheon;

      # my services
      nix-gc = import ./services/nix-gc;
      oci-container-auto-update = import ./services/oci-container-auto-update;

      default = {
        imports = [
          self.nixosModules.generic-nixos
          self.nixosModules.nix-gc
          self.nixosModules.oci-container-auto-update
        ];
      };
    };
  };
}
