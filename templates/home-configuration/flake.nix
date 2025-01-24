{
  description = "sample home-configuration";

  inputs = {
    nix-config.url = "github:hnjae/nix-config";
    # nix-config.url = "path:/home/hnjae/Projects/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager.follows = "nix-config/home-manager";
  };

  outputs = {
    nixpkgs,
    nix-config,
    home-manager,
    ...
  }: {
    homeConfigurations.my-home = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = {};
      modules = [
        {
          home = {
            username = "hnjae";
            homeDirectory = "/home/hnjae";
            stateVersion = "24.11";
          };
        }
        nix-config.homeManagerModules.base-home
      ];
    };
  };
}
