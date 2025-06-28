/*
  Homepage: https://freesentation.blog/
  용도: 프리젠테이션용 글꼴
*/
{
  stdenv,
  lib,
  fetchzip,
}:
stdenv.mkDerivation rec {
  preferLocalBuild = true;

  pname = "fonts-freesentation";
  version = "2.000"; # 2024-11-12

  src = fetchzip {
    url = "https://github.com/Freesentation/freesentation/raw/refs/heads/main/Freesentation-v${version}.zip";
    sha256 = "sha256-Kqc+1VF6LsqOpG0wkX46Syk21TvvvMetsN5M/qRlyAQ=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype"
    cp --reflink=auto Freesentation-*.ttf "$out/share/fonts/truetype"
  '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
