{
  python3,
  stdenv,
}:
stdenv.mkDerivation {
  name = "nix-delete-generations";
  propagatedBuildInputs = [python3];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./run.py} $out/bin/nix-gc-system-generations";
}
