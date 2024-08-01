# https://github.com/EricKotato/sddm-slice
{
  lib,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "sddm-theme-slice";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "EricKotato";
    repo = "sddm-slice";
    rev = "${version}";
    hash = "sha256-1AxRM2kHOzqjogYjFXqM2Zm8G3aUiRsdPDCYTxxQTyw=";
  };

  patches = [
    ./theme.conf.patch
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/slice
    cp -r * $out/share/sddm/themes/slice
  '';

  meta = with lib; {
    description = "Simple dark SDDM theme with many customization options.";
    homepage = "https://github.com/EricKotato/sddm-slice";
    license = licenses.cc-by-nc-sa-40;
    platforms = platforms.linux;
  };
}
