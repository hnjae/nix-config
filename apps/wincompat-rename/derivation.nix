{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "wincompat-rename";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = with lib; {
    description = "CLI tool to rename files to Windows-compatible names";
    mainProgram = "wincompat-rename";
    platforms = platforms.unix;
  };
}
