{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "com.google.Chrome";

  shouldApply =
    baseHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64 && pkgs.config.allowUnfree;
in
{
  config = lib.mkIf (shouldApply) {
    services.flatpak.packages = [ appId ];

    xdg.dataFile."applications/${appId}.desktop" =
      let
        flags = [
          # enable wayland
          "--ozone-platform-hint=auto"
          "--enable-features=UseOzonePlatform"
          # enable text-input-v3
          "--enable-wayland-ime"
          "--wayland-text-input-version=3"
          # enable vaapi
          "--enable-features=AcceleratedVideoDecodeLinuxGL"
          "--enable-features=VaapiIgnoreDriverChecks"
          # enable vulkan support
          # NOTE: enabling vulkan disable video play in wavve.com <2024-12-25>
          # "--enable-features=Vulkan"

          # disable global shortcuts portal
          "--disable-features=GlobalShortcutsPortal" # https://github.com/brave/brave-browser/issues/44886
        ];
        flagStr = builtins.concatStringsSep " " flags;
      in
      {
        text = ''
          [Desktop Entry]
          Version=1.0
          Name=Google Chrome
          GenericName=Web Browser
          Comment=Access the Internet
          Exec=flatpak run --branch=stable --command=/app/bin/chrome --file-forwarding com.google.Chrome ${flagStr} @@u %U @@
          StartupNotify=true
          Terminal=false
          Icon=com.google.Chrome
          Type=Application
          Categories=Network;WebBrowser;
          MimeType=application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;text/html;x-scheme-handler/http;x-scheme-handler/https;
          Actions=new-window;new-private-window;
          X-Flatpak-Tags=proprietary;
          X-Flatpak=com.google.Chrome

          [Desktop Action new-window]
          Name=New Window
          Exec=flatpak run --branch=stable --command=/app/bin/chrome com.google.Chrome ${flagStr}

          [Desktop Action new-private-window]
          Name=New Incognito Window
          Exec=flatpak run --branch=stable --command=/app/bin/chrome com.google.Chrome ${flagStr} --incognito
        '';
      };
  };
}
