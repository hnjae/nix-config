# https://github.com/EricKotato/sddm-slice
{
  lib,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "sddm-theme-corners";
  version = "20230118";

  src = fetchFromGitHub {
    owner = "aczw";
    repo = "${pname}";
    rev = "4f87e57f9776eea137f334358db02eb878585f0e";
    hash = "sha256-kBrUXMY+5ygUe+9/4nkypFo/4bHGDSEJtptyOgwyOd0=";
  };

  # patches = [
  #   ./theme.conf.patch
  # ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/corners
    cp -r corners/* $out/share/sddm/themes/corners
  '';

  meta = with lib; {
    description = "Simple dark SDDM theme with many customization options.";
    homepage = "https://github.com/aczw/sddm-theme-corners";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
