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
  version = "1.7.3"; # NOTE: 2024-01-29 checked
in
  stdenv.mkDerivation {
    pname = "plasma-applet-active-window-control";
    inherit version;

    # src = fetchgit {
    #   # NOTE: no version info on repository <2024-01-29>
    #   url = "https://phabricator.kde.org/source/plasma-active-window-control/";
    #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    # };
    src = fetchFromGitHub {
      owner = "kotelnik";
      repo = "plasma-applet-active-window-control";
      rev = "v${version}";
      sha256 = "sha256-+UCINyN+up77/ZABbH4H04rwbVCgDVZj02FQkwtuQuw=";
    };

    # patchPhase = ''
    #   substituteInPlace package/contents/ui/main.qml \
    #     --replace "redshiftCommand: 'redshift'" \
    #               "redshiftCommand: '${redshift}/bin/redshift'" \
    #     --replace "redshiftOneTimeCommand: 'redshift -O " \
    #               "redshiftOneTimeCommand: '${redshift}/bin/redshift -O "
    #
    #   substituteInPlace package/contents/ui/config/ConfigAdvanced.qml \
    #     --replace "'redshift -V'" \
    #               "'${redshift}/bin/redshift -V'"
    # '';

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
