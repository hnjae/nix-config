let
  project = "wincompat-rename";
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (pkgs) rustPlatform;
    in
    {
      packages."${project}" = import ./. { inherit pkgs; };

      checks."${project}" = rustPlatform.buildRustPackage {
        pname = "${project}-checks";
        version = "0.1.0";
        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        nativeBuildInputs = with pkgs; [
          rustfmt
          clippy
        ];

        preCheck = ''
          echo 'INFO: Running cargo fmt check...' >&2
          cargo fmt --check

          echo 'INFO: Running cargo clippy (linter)...' >&2
          cargo clippy --all-targets --all-features
        '';

        checkPhase = ''
          runHook preCheck

          echo "INFO: Running cargo test..." >&2
          cargo test --release

          runHook postCheck
        '';

        doCheck = true;
        dontInstall = true;
        installPhase = "touch $out";
      };

      apps."${project}" = {
        type = "app";
        program = config.packages."${project}";
      };

      devShells.${project} = pkgs.mkShellNoCC {
        packages = with pkgs; [
          cargo
          cargo-tarpaulin # code coverage tool
          clippy # official linter
          rust-analyzer # (officia ) rust compiler front-end for IDEs
          rustfmt # official formatter
        ];
      };
    };
}
