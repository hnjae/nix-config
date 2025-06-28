{
  stdenv,
  lib,
}:
stdenv.mkDerivation rec {
  preferLocalBuild = true;

  pname = "fonts-toss-face";
  version = "1.6.1"; # 2025-04-30 checked

  src = builtins.fetchurl {
    url = "https://github.com/toss/tossface/releases/download/v${version}/TossFaceFontMac.ttf";
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
    # homepage = "https://github.com/toss/tossface";
    license = licenses.unfree; # https://toss.im/tossface/copyright#full
    platforms = platforms.all;
  };
}
