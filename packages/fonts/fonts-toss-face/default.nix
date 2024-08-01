{
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  pname = "fonts-toss-face";
  version = "1.6"; # 2023-12-29 checked

  src = builtins.fetchurl {
    url = "https://github.com/toss/tossface/releases/latest/download/TossFaceFontMac.ttf";
    sha256 = "sha256:10s8bcz2fqscflyffbkc5b31432y8dk0mkxw8h4brid9pqqwyjgc";
  };
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype"
    cp "$src" "$out/share/fonts/truetype/TossFaceFontMac.ttf"
  '';

  meta = with lib; {
    description = "함께 만들어가는, 토스페이스.";
    homepage = "https://toss.im/tossface";
    license = licenses.unfree; # https://toss.im/tossface/copyright
    platforms = platforms.all;
  };
}
