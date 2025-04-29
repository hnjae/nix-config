{
  stdenv,
  lib,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "fonts-dmca-sans-serif";
  version = "9.0-20252"; # 2023-06-08

  src = fetchzip {
    url = "https://typedesign.replit.app/DMCAsansserif${version}.zip";
    sha256 = "sha256-wygnkotk7CkFbUK/dct4wBt8/+M4IAtJ3YHtIsJzQHg=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype"
    cp -r DMCAsansserif-*.ttf "$out/share/fonts/truetype"
  '';

  meta = with lib; {
    description = "General purpose sans serif font metric-compatible with Microsoft Consolas";
    homepage = "https://typedesign.repl.co/dmcasansserif.html";
    license = licenses.publicDomain;
    platforms = platforms.all;
  };
}
