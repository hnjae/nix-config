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
      oci-container-auto-update = import ./oci-container-auto-update;
      nix-gc = import ./nix-gc;

      default = {
        imports = [
          self.nixosModules.generic-nixos
          self.nixosModules.oci-container-auto-update
          self.nixosModules.nix-gc
        ];
      };
    };
  };
}
