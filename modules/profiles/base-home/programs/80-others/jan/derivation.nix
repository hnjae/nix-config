{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
}:

let
  pname = "jan";
  version = "0.5.16";
  src = fetchurl {
    url = "https://github.com/janhq/jan/releases/download/v${version}/jan-linux-x86_64-${version}.AppImage";
    hash = "sha256-oKJSX8VuCS/CzIroYYzuEtyfviv3naxYr8jpfUccxBg=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  preferLocalBuild = true;

  inherit pname version src;

  nativeBuildInputs = [
    makeWrapper
  ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/jan.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/jan.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=jan'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = {
    changelog = "https://github.com/janhq/jan/releases/tag/v${version}";
    description = "Jan is an open source alternative to ChatGPT that runs 100% offline on your computer";
    homepage = "https://github.com/janhq/jan";
    license = lib.licenses.agpl3Plus;
    mainProgram = "jan";
    maintainers = [ ];
    platforms = with lib.systems.inspect; patternLogicalAnd patterns.isLinux patterns.isx86_64;
  };
}
