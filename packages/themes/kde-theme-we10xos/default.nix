{
  stdenv,
  lib,
  fetchFromGitHub,
}:
# Win11OS-kde
# https://github.com/yeyushengfan258/Win11OS-kde
stdenv.mkDerivation rec {
  pname = "kde-theme-we10xos";
  # NOTE: 2024-02-24 checked
  version = "2023-05-14";

  src = fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "We10XOS-kde";
    rev = "2379e9bed9ce7e7b6ee41c93ac1584cda7f07b5e";
    sha256 = "sha256-5LcP3ILdzGEsnyucz1nlApl3SAuWuBjWPEo+rQlVa3Q=";
  };

  # These fixup steps are slow and unnecessary
  # dontPatchELF = true;
  # dontRewriteSymlinks = true;

  # postPatch = ''
  #   patchShebangs install.sh
  # '';

  installPhase = ''
    runHook preInstall

    # Destination directory
    AURORAE_DIR="$out/share/aurorae/themes"
    SCHEMES_DIR="$out/share/color-schemes"
    PLASMA_DIR="$out/share/plasma/desktoptheme"
    LAYOUT_DIR="$out/share/plasma/layout-templates"
    LOOKFEEL_DIR="$out/share/plasma/look-and-feel"
    KVANTUM_DIR="$out/share/Kvantum"
    WALLPAPER_DIR="$out/share/wallpapers"

    THEME_NAME=We10XOS

    [[ ! -d ''${AURORAE_DIR} ]] && mkdir -p ''${AURORAE_DIR}
    [[ ! -d ''${SCHEMES_DIR} ]] && mkdir -p ''${SCHEMES_DIR}
    [[ ! -d ''${PLASMA_DIR} ]] && mkdir -p ''${PLASMA_DIR}
    [[ ! -d ''${LOOKFEEL_DIR} ]] && mkdir -p ''${LOOKFEEL_DIR}
    [[ ! -d ''${KVANTUM_DIR} ]] && mkdir -p ''${KVANTUM_DIR}
    [[ ! -d ''${WALLPAPER_DIR} ]] && mkdir -p ''${WALLPAPER_DIR}

    SRC_DIR=$(pwd)
    cp --reflink=auto -r ''${SRC_DIR}/aurorae/* ''${AURORAE_DIR}
    cp --reflink=auto -r ''${SRC_DIR}/color-schemes/*.colors ''${SCHEMES_DIR}
    cp --reflink=auto -r ''${SRC_DIR}/Kvantum/* ''${KVANTUM_DIR}
    cp --reflink=auto -r ''${SRC_DIR}/plasma/desktoptheme/* ''${PLASMA_DIR}
    cp --reflink=auto -r ''${SRC_DIR}/plasma/look-and-feel/* ''${LOOKFEEL_DIR}
    cp --reflink=auto -r ''${SRC_DIR}/wallpaper/* ''${WALLPAPER_DIR}

    runHook postInstall
  '';

  meta = with lib; {
    description = "We10XOS kde is a light clean theme for KDE Plasma desktop.";
    homepage = "https://github.com/yeyushengfan258/We10XOS-kde";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
