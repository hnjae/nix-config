{inputs, ...}: {
  flake.homeManagerModules = rec {
    default-app = import ./default-app;
    python = import ./python;
    stateful = import ./stateful;
    generic-home = import ./generic-home;

    default = {
      imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.base16.homeManagerModule
        inputs.nix-index-database.hmModules.nix-index
        inputs.nix-web-app.homeManagerModules.default

        default-app
        python
        stateful
        generic-home
      ];
    };

    plasma = {
      imports = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
        ./plasma
      ];
    };
    gnome = {imports = [./gnome];};
  };
}
