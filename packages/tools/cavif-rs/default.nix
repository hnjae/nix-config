{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "cavif-rs";
  version = "1.5.2"; # 2023-05-08

  src = fetchzip {
    name = "cavif.zip";
    url = "https://github.com/kornelski/${pname}/releases/download/v${version}/cavif-${version}.zip";
    sha256 = "sha256-s4j/hyLLnM6LRIr/wf57DjIsqINlbbKzXAN/m3v3v44=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp linux-generic/cavif $out/bin
  '';

  meta = with lib; {
    description = "Encoder/converter for AVIF images";
    homepage = "https://github.com/kornelski/cavif-rs";
    license = licenses.bsd3;
  };
}
