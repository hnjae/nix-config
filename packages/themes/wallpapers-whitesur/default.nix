{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "wallpapers-whitesur";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-wallpapers";
    rev = "v${version}";
    sha256 = "sha256-zO6wdwJH3VhR+Y1clPeV5BwxXS0FA9vZvPa1IKpnKvs=";
  };

  installPhase = ''
    runHook preInstall

    patchShebangs install-wallpapers.sh

    substituteInPlace install-wallpapers.sh \
      --replace '$HOME/.local/share/backgrounds' $out/share/wallpapers

    name= ./install-wallpapers.sh -s 4k

    # --dest $out/share/themes

    runHook postInstall
  '';

  meta = with lib; {
    description = "MacOS big sur like wallpapers.";
    homepage = "https://github.com/vinceliuice/WhiteSur-wallpapers";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
