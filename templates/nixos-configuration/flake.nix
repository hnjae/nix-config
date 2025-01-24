{
  description = "sample nixos-configration";

  inputs = {
    nix-config.url = "github:hnjae/nix-config";
    # nix-config.url = "path:/home/hnjae/Projects/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nix-config,
      ...
    }@inputs:
    {
      nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nix-config.nixosModules.base-nixos
          {
            nixpkgs.system = "x86_64-linux";
            fileSystems."/".label = "foo";
            boot.loader.systemd-boot.enable = true;
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
