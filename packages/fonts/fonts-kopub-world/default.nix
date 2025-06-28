{
  stdenv,
  lib,
  fetchzip,
}:
stdenv.mkDerivation {
  preferLocalBuild = true;

  pname = "fonts-kopub-world";
  version = "1.1.1"; # 2021-03 # 2023-06-08

  src = fetchzip {
    url = "https://www.kopus.org/wp-content/uploads/2021/03/KOPUBWORLD_OTF_FONTS.zip";
    sha256 = "sha256-jF+b4WNToENOp5tsWTOWeQFg/8nUSb3uCMidAiIOB4c=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    cp * "$out/share/fonts/opentype"
  '';

  meta = with lib; {
    description = "Digital screen-friendly Korean fonts";
    homepage = "http://www.kopus.org/biz-electronic-font2/";
    # https://www.kopus.org/wp-content/uploads/2021/04/서체_라이선스.pdf
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
