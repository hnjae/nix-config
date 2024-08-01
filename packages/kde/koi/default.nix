{
  lib,
  mkDerivation,
  cmake,
  fetchFromGitHub,
  wrapQtAppsHook,
  kcoreaddons,
  kwidgetsaddons,
  kconfig,
  kwindowsystem,
}:
mkDerivation rec {
  pname = "koi";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "baduhai";
    repo = "Koi";
    rev = "${version}";
    name = pname;
    sha256 = "sha256-QJCnS12m58X6NtmzsFQ/O0yLlWp98OgaEhFWCxzyIaI=";
  };

  buildInputs = [
    wrapQtAppsHook
    kcoreaddons
    kwidgetsaddons
    kconfig
  ];

  nativeBuildInputs = [cmake];

  sourceRoot = "${src.name}/src";

  meta = {
    description = "Theme scheduling for the KDE Plasma Desktop";
    license = lib.licenses.lgpl3;
    homepage = "https://github.com/baduhai/Koi";
    inherit (kwindowsystem.meta) platforms;
  };
}
