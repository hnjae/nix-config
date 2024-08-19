{
  self,
  inputs,
  ...
}: {
  flake.homeManagerModules = {
    base24 = import ./base24;
    default-app = import ./default-app;
    python = import ./python;
    stateful = import ./stateful;
    generic-home = import ./generic-home;

    de-gnome = import ./de-gnome;
    de-plasma5 = import ./de-plasma5;
    de-plasma6 = import ./de-plasma6;
    de-sway = import ./de-sway;

    default = {
      imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.base16.homeManagerModule
        inputs.nix-index-database.hmModules.nix-index
        inputs.nix-web-app.homeManagerModules.default

        self.homeManagerModules.base24
        self.homeManagerModules.default-app
        self.homeManagerModules.python
        self.homeManagerModules.stateful
        self.homeManagerModules.generic-home
      ];
    };
  };
}
