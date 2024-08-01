# NOTE: WIP <2024-02-01>
{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  plasma-framework,
  # kwindowsystem,
  # qtgraphicaleffects,
  fetchFromGitHub,
  libSM,
  qtx11extras,
}: let
  version = "";
in
  stdenv.mkDerivation {
    pname = "plasma-applet-latte-separator";
    inherit version;

    src = fetchFromGitHub {
      owner = "psifidotos";
      repo = "applet-latte-separator";
      rev = "v${version}";
      sha256 = "";
    };

    nativeBuildInputs = [
      cmake
      extra-cmake-modules
    ];

    buildInputs = [
      plasma-framework
      # kwindowsystem
      # qtgraphicaleffects
      qtx11extras
      libSM
    ];

    dontWrapQtApps = true;

    meta = with lib; {
      description = "Plasmoid which just show active window title and icon.";
      homepage = "https://store.kde.org/p/998910";
      license = licenses.gpl2;
      platforms = platforms.linux;
      # maintainers = with maintainers; [ benley zraexy ];
    };
  }
