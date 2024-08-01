# TODO: remove this in NixOS 24.11  <2024-07-11>
# not available in NixOS 24.05
/*
Copyright (c) 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
{
  lib,
  stdenv,
  fetchFromGitHub,
  kdePackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "application-title-bar";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "antroids";
    repo = "application-title-bar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-r15wZCioWrTr5mA0WARFd4j8zwWIWU4wEv899RSURa4=";
  };

  propagatedUserEnvPkgs = with kdePackages; [kconfig];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/com.github.antroids.application-title-bar
    cp -r package/* $out/share/plasma/plasmoids/com.github.antroids.application-title-bar
    runHook postInstall
  '';

  meta = {
    description = "KDE Plasma6 widget with window controls";
    homepage = "https://github.com/antroids/application-title-bar";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [HeitorAugustoLN];
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
})
