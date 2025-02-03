_: {
  flake = {
    nixosModules.gnome = import ./nixos-module;
    /*
      Module Dependency:
        * home-manager
        * base-home
    */
    homeManagerModules.gnome = import ./hm-module;
  };
}
