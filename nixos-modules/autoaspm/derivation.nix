{
  lib,
  stdenv,
  makeWrapper,
  pciutils,
  python3,
}:

stdenv.mkDerivation {
  pname = "autoaspm";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ pciutils ];

  installPhase = ''
    runHook preInstall

    install -Dm755 autoaspm.py $out/libexec/autoaspm/autoaspm.py

    makeWrapper ${python3.interpreter} "$out/bin/autoaspm" \
      --add-flags "$out/libexec/autoaspm/autoaspm.py" \
      --prefix PATH : ${lib.makeBinPath [ pciutils ]}

    # Install shell completions
    install -Dm644 completions/autoaspm.bash $out/share/bash-completion/completions/autoaspm
    install -Dm644 completions/autoaspm.fish $out/share/fish/vendor_completions.d/autoaspm.fish
    install -Dm644 completions/_autoaspm $out/share/zsh/site-functions/_autoaspm
    install -Dm644 completions/autoaspm.nu $out/share/nu/vendor/autocompletions/autoaspm.nu

    runHook postInstall
  '';

  meta = {
    description = "Automatically enable ASPM on all supported PCIe devices";
    platforms = lib.platforms.linux;
    mainProgram = "autoaspm";
  };
}
