{
  lib,
  stdenv,
  fetchFromGitHub,
  kdePackages,
}:
stdenv.mkDerivation rec {
  pname = "compact-pager";
  version = "3.3-rc2"; # 2024-07-10

  src = fetchFromGitHub {
    owner = "tilorenz";
    repo = "compact_pager";
    rev = "v${version}";
    name = pname;
    sha256 = "sha256-DX8nFMCJJN7Y6D1sND7mxnkX91SIgDPTl/YQJxYxYCM=";
  };

  installPhase = ''
    mkdir -p "$out/share/plasma/plasmoids"
    cp -r "$src/package" "$out/share/plasma/plasmoids/com.github.tilorenz.compact_pager"
  '';

  meta = {
    description = "A compact pager for the KDE Plasma desktop.";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/tilorenz/compact_pager";
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
}
