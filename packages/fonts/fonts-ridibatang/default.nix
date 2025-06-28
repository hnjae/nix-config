{
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  preferLocalBuild = true;

  pname = "fonts-ridibatang";
  version = "1.0.1"; # 2019-10-01 build # 2023-06-18

  src = builtins.fetchurl {
    url = "https://ridicorp.com/wp-content/themes/ridicorp/css/font/RIDIBatang.otf";
    sha256 = "sha256:0m4sv97lrlgf9vjpicyf13n3sqann2h56a9rbv0ll9axh704jfpi";
  };
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    cp "$src" "$out/share/fonts/opentype/RIDIBatang.otf"
  '';

  meta = with lib; {
    description = "더 선명하고, 긴 문장도 잘 읽을 수 있는 전자책 전용 글꼴";
    homepage = "https://ridicorp.com/ridibatang/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
