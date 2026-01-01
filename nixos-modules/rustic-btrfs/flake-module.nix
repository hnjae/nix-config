/*
  A module to import into flakes based on flake-parts.
  Makes integration into a flake easy and tidy.
  See https://flake.parts,
*/

let
  projectName = "rustic-btrfs";
in
{
  flake-parts-lib,
  inputs,
  self,
  ...
}:
let
  inherit (flake-parts-lib) importApply;
  flakeArgs = {
    localFlake = self;
    inherit projectName;
  };
in
{
  flake.nixosModules.${projectName} = importApply ./nixos-module.nix flakeArgs;

  perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:
    let
      isSupported = builtins.elem system [
        "aarch64-linux"
        "x86_64-linux"
      ];

      craneLib = inputs.crane.mkLib pkgs;

      # Common arguments can be set here to avoid repeating them later
      # Note: changes here will rebuild all dependency crates
      commonArgs = {
        src = craneLib.cleanCargoSource ./.;
        strictDeps = true;

        buildInputs = [
          # Add additional build inputs here
        ];
      };

      my-crate = craneLib.buildPackage (
        commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          # Additional environment variables or build phases/hooks can be set
          # here *without* rebuilding all dependency crates
          # MY_CUSTOM_VAR = "some value";

          meta = {
            description = "";
            mainProgram = "rustic-btrfs";
            platforms = lib.platforms.linux;
          };
        }
      );
    in
    lib.optionalAttrs isSupported {
      packages.${projectName} = my-crate;

      # Build the crate as part of `nix flake check` for convenience
      checks.${projectName} = my-crate;

      apps.${projectName} = {
        type = "app";
        program = config.packages.${projectName};
      };

      devShells.${projectName} = craneLib.devShell {
        packages = with pkgs; [
          cargo-tarpaulin # code coverage tool
          rust-analyzer # (official) rust compiler front-end for IDEs
        ];
      };
    };
}
