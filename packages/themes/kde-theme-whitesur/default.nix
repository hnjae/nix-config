{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "kde-theme-whitesur";
  version = "2022-05-01";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "WhiteSur-kde";
    rev = version;
    sha256 = "sha256-hgkou6uag4itcFo9VGKREZ1lG3AL4HG0C2DMS/uq1PU=";
  };

  installPhase =
    ''
      runHook preInstall

    ''
    + builtins.readFile ./install.sh
    + ''

      runHook postInstall
    '';

  meta = with lib; {
    description = "MacOS big sur like theme for KDE Plasma desktop.";
    homepage = "https://github.com/vinceliuice/WhiteSur-kde";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
