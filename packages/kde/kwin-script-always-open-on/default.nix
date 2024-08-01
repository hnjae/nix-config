{
  lib,
  mkDerivation,
  kcoreaddons,
  kwindowsystem,
  plasma-framework,
  systemsettings,
  fetchFromGitHub,
}:
mkDerivation rec {
  pname = "kwin-script-always-open-on";
  version = "v5.0";

  src = fetchFromGitHub {
    owner = "nclarius";
    repo = "KWin-window-positioning-scripts";
    rev = "fe9d1641982912075f9debe68cc6b9afde7292d5";
    name = pname;
    sha256 = "sha256-T4fFQmniWYgLWEfjnBqvhj7b43werJh/DmdP03eLjeY=";
  };

  buildInputs = [
    kcoreaddons
    kwindowsystem
    plasma-framework
    systemsettings
  ];

  dontBuild = true;

  # 1. --global still installs to $HOME/.local/share so we use --packageroot
  # 2. plasmapkg2 doesn't copy metadata.desktop into place, so we do that manually
  installPhase = ''
    runHook preInstall

    mkdir -p $out

    for tp in active focused primary; do
      src="${src}/always-open-on-''${tp}-screen"
      pname="alwaysopenon''${tp}screen"

      plasmapkg2 --type kwinscript --install "$src" --packageroot $out/share/kwin/scripts
      install -Dm644 "''${src}/metadata.json" "$out/share/kservices5/''${pname}.json"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Collection of small extensions for KDE’s window manager controlling window placement on multi-monitor setups";
    license = licenses.gpl3;
    homepage = "https://github.com/nclarius/KWin-window-positioning-scripts";
    inherit (kwindowsystem.meta) platforms;
  };
}
