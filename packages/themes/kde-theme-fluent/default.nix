{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "kde-theme-fluent";
  version = "2023-02-11";

  srcs = [
    (fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Fluent-kde";
      rev = "d7576a7867c7dc6ddd6eefaa96622b6434cb7ea7";
      sha256 = "sha256-dTc3mOX4vq3BjXsc+Hq6LgsnDBu5FDRRqNVuWtjRG1M=";
    })
    # ../kde-start-icon.svg
  ];
  sourceRoot = "source";

  installPhase =
    ''
      runHook preInstall

    ''
    + builtins.readFile ./install.sh
    + ''

      # cp ../kde-start-icon.svg $out/share/plasma/desktoptheme/Fluent/icons/start.svg
      # cp ../kde-start-icon.svg $out/share/plasma/desktoptheme/Fluent-round/icons/start.svg

      rm -f $out/share/plasma/desktoptheme/Fluent/icons/start.svgz
      rm -f $out/share/plasma/desktoptheme/Fluent-round/icons/start.svgz

      runHook postInstall
    '';

  meta = with lib; {
    description = "Microsoft fluent Design theme for KDE Plasma desktop.";
    homepage = "https://github.com/vinceliuice/Fluent-kde";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
