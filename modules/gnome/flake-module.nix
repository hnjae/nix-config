_: {
  flake = {
    nixosModules.gnome = import ./nixosModule;
    /*
    Module Dependency:
      * home-manager
      * generic-home
    */
    homeManagerModules.gnome = import ./homeManagerModule;
  };
}
