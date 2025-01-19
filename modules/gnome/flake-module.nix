_: {
  flake = {
    nixosModules.gnome = import ./nixosModule;
    homeManagerModules.gnome = import ./homeManagerModule;
  };
}
