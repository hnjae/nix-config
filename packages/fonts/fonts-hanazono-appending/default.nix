{
  stdenv,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "fonts-hanazono-appending";
  version = "0.0.1"; # 2023-06-08 checked

  src = builtins.fetchurl {
    url = "http://glyphwiki.org/font/gw3664726.ttf";
    sha256 = "sha256-0I8r/aq72lYUhajRC4wjkKXtKTlUmxZcXJ4EZ/grUlM=";
  };
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype"
    cp "$src" "$out/share/fonts/truetype/cutra_AppendingToHanaMin.ttf"
  '';

  meta = with lib; {
    description = "cutra_AppendingToHanaMin";
    homepage = "http://glyphwiki.org/wiki/Group:cutra_AppendingToHanaMin";
    license = licenses.unfree; # unknown
    platforms = platforms.all;
  };
}
