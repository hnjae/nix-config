{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  preferLocalBuild = true;

  pname = "fonts-plangothic";
  version = "0.8.5735"; # 2023-05-14

  srcs = [
    (fetchFromGitHub {
      owner = "Fitzgerald-Porthmouth-Koenigsegg";
      repo = "Plangothic-Project";
      rev = "V${version}";
      sha256 = "sha256-og98Zz2uuNEWVtGXUkGldx7JNwkqklGhKIfgo14kKvE=";
    })
  ];
  sourceRoot = "source";

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype"
    cp "./PlangothicP1-Regular (allideo).ttf" "$out/share/fonts/truetype"
    cp "./PlangothicP2-Regular.ttf" "$out/share/fonts/truetype"
  '';

  meta = with lib; {
    description = "Plangothic Project (Chinese: 遍黑体项目) is based on Source Han Sans CN and takes the Chinese Mainland glyphs as the standard to supplement the CJKV Unified ideographic extension";
    homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic-Project";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
