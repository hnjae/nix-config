# https://github.com/easymodo/qimgv
{
  lib,
  stdenv,
  fetchFromGitHub,
  # to build
  cmake,
  pkg-config,
  # qt
  qtbase,
  qttools,
  # optional
  opencv4,
  exiv2,
  # mpv,
  mpv-unwrapped,
  # image supports
  qtimageformats,
  qtsvg,
  kimageformats,
}:
stdenv.mkDerivation {
  pname = "qimgv";
  version = "unstable-2024-07-27"; # 2024-08-10 checked

  src = fetchFromGitHub {
    owner = "easymodo";
    repo = "qimgv";
    rev = "82e6b7537002b86b4ab20954aab5bf0db7c25752";
    hash = "sha256-FboaMevbzsKZSfbalVI4Kwwgp4Lbct3KDE6xKufzGtc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qtbase
    qttools
    # optional
    exiv2
    opencv4
    mpv-unwrapped
    # image supports
    qtimageformats
    qtsvg
    kimageformats # for jxl
  ];

  cmakeFlags = [
    "-DVIDEO_SUPPORT=ON"
    "-DEXIV2=ON"
    "-DOPENCV_SUPPORT=ON"
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Image viewer. Fast, easy to use. Optional video support";
    homepage = "https://github.com/easymodo/qimgv";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [];
    mainProgram = "qimgv";
    platforms = platforms.linux;
  };
}
