/*
  README:
    Requires:
      * `/secrets/home-age-private`
*/
{
  inputs,
  self,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
in
{
  flake.nixosModules.base-nixos = {
    imports = [
      ./.

      (importApply ./with-import-apply/build-farms {
        localFlake = self;
        inherit flake-parts-lib;
      })
      (importApply ./with-import-apply/deploy-account.nix { localFlake = self; })
      (importApply ./with-import-apply/home-manager.nix { localFlake = self; })
      (importApply ./with-import-apply/nix-registry.nix { inherit inputs; })
      (importApply ./with-import-apply/nixpkgs.nix { localFlake = self; })
      (importApply ./with-import-apply/users.nix { localFlake = self; })

      self.nixosModules.nix-gc-system-generations
      self.nixosModules.nix-store-gc
      self.nixosModules.oci-container-auto-update
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops

      inputs.nix-modules-private.nixosModules.base-home-extend
    ];
  };
}
