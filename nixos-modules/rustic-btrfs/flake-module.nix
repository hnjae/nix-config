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

        nativeBuildInputs = with pkgs; [
          pkg-config
          clang # For bindgen
        ];

        buildInputs = with pkgs; [
          btrfs-progs # Provides libbtrfsutil
        ];

        # Bindgen requires libclang
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      };

      my-crate = craneLib.buildPackage (
        commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          # Additional environment variables or build phases/hooks can be set
          # here *without* rebuilding all dependency crates
          # MY_CUSTOM_VAR = "some value";

          nativeBuildInputs =
            commonArgs.nativeBuildInputs
            ++ (with pkgs; [
              installShellFiles
              makeWrapper
            ]);

          postInstall = ''
            # Wrap with rclone in PATH (required for rustic_core remote backends)
            wrapProgram "$out/bin/rustic-btrfs" \
              --prefix PATH : "${lib.makeBinPath [ pkgs.rclone ]}"

            # Generate and install shell completions
            for shell in bash fish zsh; do
              $out/bin/rustic-btrfs --generate-completion "$shell" > "rustic-btrfs.$shell"
            done
            installShellCompletion rustic-btrfs.{bash,fish,zsh}

            # Generate and install manpage
            mkdir -p $out/share/man/man1
            $out/bin/rustic-btrfs --generate-manpage > $out/share/man/man1/rustic-btrfs.1
          '';

          meta = {
            description = "Safely backup Btrfs subvolumes using rustic";
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
        # Inherit build inputs from commonArgs
        inputsFrom = [ my-crate ];

        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib"; # bindgen requirement

        packages = with pkgs; [
          cargo-tarpaulin # code coverage tool
          rust-analyzer # (official) rust compiler front-end for IDEs
          rclone # Required for rustic_core remote backends
        ];
      };
    };
}
