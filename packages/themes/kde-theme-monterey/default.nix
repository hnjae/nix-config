{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "kde-theme-monterey";
  version = "2023-08-13";

  srcs = [
    (fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Monterey-kde";
      rev = "4eada67e6f41b97b8a55cd23741ef1e415dc244b";
      sha256 = "sha256-B8MVIOGedm3ddqTQUQHqzHX/uDg0m5ZpjNyaJwgzRQo=";
    })
    # ./kde-start-icon.svg
  ];
  sourceRoot = "source";

  installPhase =
    ''
      runHook preInstall

    ''
    + builtins.readFile ./install.sh
    + ''

      # cp ./kde-start-icon.svg $out/share/plasma/desktoptheme/Monterey/icons/start.svg
      # cp ./kde-start-icon.svg $out/share/plasma/desktoptheme/Monterey-dark/icons/start.svg

      runHook postInstall
    '';

  meta = with lib; {
    description = "MacOS Monterey like theme for KDE Plasma desktop.";
    homepage = "https://github.com/vinceliuice/Monterey-kde";
    license = licenses.lgpl3Only;
    platforms = platforms.linux;
  };
}
