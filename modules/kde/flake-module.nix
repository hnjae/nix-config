{
  flake = {
    nixosModules.kde = {
      imports = [
        ./nixos-module
        {
          home-manager.sharedModules = [
            (import ./hm-module)
          ];
        }
      ];
    };

    # /*
    #   Module Dependency:
    #     * home-manager
    #     * base-home
    # */
    homeManagerModules.kde = import ./hm-module;
  };
}
