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

      (importApply ./with-import-apply/home-manager.nix { localFlake = self; })
      (importApply ./with-import-apply/nix-registry.nix { inherit inputs; })
      (importApply ./with-import-apply/nixpkgs.nix { localFlake = self; })
      (importApply ./with-import-apply/users.nix { localFlake = self; })

      self.nixosModules.nix-gc-system-generations
      self.nixosModules.nix-store-gc
      inputs.home-manager.nixosModules.home-manager

      inputs.sops-nix.nixosModules.sops
      inputs.nix-modules-private.nixosModules.my-build-farms
    ];
  };
}
