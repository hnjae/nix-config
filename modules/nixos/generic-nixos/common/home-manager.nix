{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.base16.homeManagerModule
      inputs.nix-index-database.hmModules.nix-index
      inputs.nix-web-app.homeManagerModules.default

      (import ../../../home-manager/default-app)
      (import ../../../home-manager/python)
      (import ../../../home-manager/stateful)
      (import ../../../home-manager/generic-home)
    ];
    extraSpecialArgs = {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv) system;
        config.allowUnfree = pkgs.config.allowUnfree;
        overlays = [
          inputs.rust-overlay.overlays.default
        ];
      };
    };
  };
}
