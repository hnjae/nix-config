{self, ...}: {
  flake = {
    nixosModules = {
      generic-nixos = import ./generic-nixos;

      # generic-desktop = import ./generic-desktop;
      # desktop-packages = import ./desktop-packages;

      de-plasma5 = import ./de-plasma5;
      de-plasma6 = import ./de-plasma6;
      ds-gnome = import ./de-gnome;
      ds-sway = import ./de-sway;
      ds-pantheon = import ./de-pantheon;

      # nix-collect-garbage = import ./nix-collect-garbage.nix;
      expose-fhs-resources = import ./expose-fhs-resources;
      # services-flatpak = import ./services-flatpak;

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
