/*
  README:
    Requires:
      - `/secrets/home-age-private`
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
      (
        # Help is available in the configuration.nix(5) man page
        # and in the NixOS manual (accessible by running ‘nixos-help’).
        { lib, ... }:
        let
          inherit (lib) types mkOption;
        in
        {
          options.base-nixos = {
            hostType = mkOption {
              type = types.enum [
                "vm"
                "baremetal"
              ];
              default = "baremetal";
              description = "The hardware type of the machine";
            };
            role = mkOption {
              type = types.enum [
                "desktop"
                "none"
              ];
              default = "none";
              description = "System role/purpose";
            };
          };

        }
      )
      ./configs
      ./core
      ./misc
      ./non-declarative
      ./packages
      ./role

      (importApply ./with-import-apply/build-farms {
        localFlake = self;
        inherit flake-parts-lib;
      })
      (importApply ./with-import-apply/deploy-account.nix { localFlake = self; })
      (importApply ./with-import-apply/home-manager.nix { localFlake = self; })
      (importApply ./with-import-apply/nix-registry.nix {
        inherit inputs;
        localFlake = self;
      })
      (importApply ./with-import-apply/nixpkgs.nix {
        inherit inputs;
        localFlake = self;
      })
      (importApply ./with-import-apply/users.nix { localFlake = self; })

      self.nixosModules.nix-gc-system-generations
      self.nixosModules.nix-store-gc
      self.nixosModules.oci-container-auto-update
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops

      inputs.xremap.nixosModules.default
      (
        { lib, ... }:
        {
          # xremap was enable by default <2025-03-23>
          config.services.xremap.enable = lib.mkOverride 999 false;
        }
      )

      inputs.nix-modules-private.nixosModules.base-home-extend
    ];
  };
}
