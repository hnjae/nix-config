{
  perSystem =
    { pkgs, config, ... }:
    let
      inherit (pkgs) rustPlatform;
    in
    {
      packages = {
        wincompat-rename = import ./. { inherit pkgs; };
      };

      checks = {
        wincompat-rename = rustPlatform.buildRustPackage {
          pname = "wincompat-rename-checks";
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
      };

      apps = {
        wincompat-rename = {
          type = "app";
          program = config.packages.wincompat-rename;
        };
      };
    };
}
