{
  lib,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage {
  pname = "wincompat-rename";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd wincompat-rename \
      --bash completions/wincompat-rename.bash \
      --zsh completions/_wincompat-rename \
      --fish completions/wincompat-rename.fish \
      --nushell completions/wincompat-rename.nu
  '';

  meta = with lib; {
    description = "CLI tool to rename files to Windows-compatible names";
    mainProgram = "wincompat-rename";
    platforms = platforms.unix;
  };
}
