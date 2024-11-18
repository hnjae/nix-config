{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  # NOTE: Vivaldi does not support wayland <2024-06-05; vivaldi v6.7.3329.31, NixOS 24.05>

  config = lib.mkIf (genericHomeCfg.isDesktop && pkgs.config.allowUnfree) {
    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/vivaldi";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.xdg.configHome}/vivaldi-snapshot";
        mode = "700";
        type = "dir";
      }
    ];

    # default-app.browser = "vivaldi-stable";

    home.packages = lib.lists.optionals pkgs.stdenv.isLinux [
      /*
      Based on following code:

      Author: JRodez from Github
      https://github.com/NixOS/nixpkgs/pull/292148#issuecomment-2133084819

      Which follows following license:

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

      ((pkgs.vivaldi.overrideAttrs (oldAttrs: {
          dontWrapQtApps = false;
          dontPatchELF = true;
          nativeBuildInputs =
            oldAttrs.nativeBuildInputs
            ++ [pkgs.kdePackages.wrapQtAppsHook];
          inherit (pkgsUnstable.vivaldi) version src;
        }))
        .override {
          # enableWidevine = true;
          # widevine-cdm = pkgs.widevine-cdm.overrideAttrs {
          #   inherit (pkgsUnstable.widevine-cdm) version src;
          # };
          proprietaryCodecs = true;
          vivaldi-ffmpeg-codecs =
            pkgs.vivaldi-ffmpeg-codecs.overrideAttrs
            (_: {inherit (pkgsUnstable.vivaldi-ffmpeg-codecs) version src;});
        })
    ];
  };
}
