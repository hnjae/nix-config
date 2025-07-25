{
  flake = {
    nixosModules.gnome = {
      imports = [
        ./nixos-module
        {
          home-manager.sharedModules = [
            (import ./hm-module)
          ];
        }
      ];
    };
    /*
      Module Dependency:
        * home-manager
        * base-home
    */
    homeManagerModules.gnome = import ./hm-module;
  };
}
