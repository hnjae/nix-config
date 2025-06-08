{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  cfg = config.base-home;
  package = (
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
    (pkgs.vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
        pkgs.kdePackages.wrapQtAppsHook
      ];
      inherit (pkgsUnstable.vivaldi) version src;
    })).override
      {
        # enableWidevine = true;
        # widevine-cdm = pkgs.widevine-cdm.overrideAttrs {
        #   inherit (pkgsUnstable.widevine-cdm) version src;
        # };
        proprietaryCodecs = true;
        vivaldi-ffmpeg-codecs = pkgs.vivaldi-ffmpeg-codecs.overrideAttrs (_: {
          inherit (pkgsUnstable.vivaldi-ffmpeg-codecs) version src;
        });
      }
  );

  flags = [
    # enable wayland
    "--ozone-platform-hint=auto"
    "--enable-features=UseOzonePlatform"

    # enable text-input-v3
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"

    # disable global shortcuts portal
    "--disable-features=GlobalShortcutsPortal" # https://github.com/brave/brave-browser/issues/44886
  ];

  flagsStr = builtins.concatStringsSep " " flags;
in
{
  # NOTE: Vivaldi does not support wayland <2024-06-05; vivaldi v6.7.3329.31, NixOS 24.05>
  config = lib.mkIf (cfg.isDesktop && pkgs.config.allowUnfree && pkgs.stdenv.isLinux) {
    default-app.browser = "vivaldi-stable";

    home.packages = [ package ];

    # NOTE: desktopEntries does not work in Gnome <NixOS 24.11; Gnome 47>
    # vivaldi 는 NIX_OZONE_WL=1 플래그가 적용이 안됨 <NixOS 24.11>
    xdg.dataFile."applications/vivaldi-stable.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Version=1.0
        Name=Vivaldi
        GenericName=Web Browser
        Comment=Access the Internet
        Exec=${package}/bin/vivaldi ${flagsStr} %U
        StartupNotify=true
        Terminal=false
        Icon=vivaldi
        Type=Application
        Categories=Network;WebBrowser;
        MimeType=application/pdf;application/rdf+xml;application/xhtml+xml;application/xhtml_xml;application/xml;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;
        Actions=new-window;new-private-window;

        [Desktop Action new-window]
        Name=New Window
        Exec=${package}/bin/vivaldi ${flagsStr} --new-window

        [Desktop Action new-private-window]
        Name=New Private Window
        Exec=${package}/bin/vivaldi ${flagsStr} --incognito
      '';
    };
  };
}
