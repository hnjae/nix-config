_: {
  flake = {
    nixosModules.gnome = import ./nixosModule;
    /*
      Module Dependency:
        * home-manager
        * base-home
    */
    homeManagerModules.gnome = import ./homeManagerModule;
  };
}
