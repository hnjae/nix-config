# <https://github.com/brave/brave-browser/issues/42761> text-input-v3 이슈

{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "com.brave.Browser";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux && pkgs.stdenv.is64bit) {
    services.flatpak.packages = [ appId ];
    services.flatpak.overrides."${appId}" = {
      "Context" = {
        filesystems = [
          "xdg-config/BraveSoftware/Brave-Browser/NativeMessagingHosts:ro"
          "~/.1password/agent.sock"
          "~/.persist/.1password/agent.sock"
        ];
      };
    };

    # xdg.mimeApps.associations.removed =
    #   let
    #     desktopName = "${appId}.desktop";
    #     mimeTypes = [
    #       "application/pdf"
    #       "application/rdf+xml"
    #       "application/rss+xml"
    #       "image/gif"
    #       "image/jpeg"
    #       "image/png"
    #       "image/webp"
    #       "text/xml"
    #     ];
    #   in
    #   (builtins.listToAttrs (
    #     builtins.map (mimeType: {
    #       name = mimeType;
    #       value = desktopName;
    #     }) mimeTypes
    #   ));
    #
    # stateful.nodes = [
    #   {
    #     path = "${config.xdg.configHome}/BraveSoftware";
    #     mode = "700";
    #     type = "dir";
    #   }
    # ];
    #
    # xdg.dataFile."applications/${appId}.desktop" =
    #   let
    #     flags = [
    #       # enable wayland
    #       "--ozone-platform-hint=auto"
    #       "--enable-features=UseOzonePlatform"
    #
    #       # enable text-input-v3
    #       "--enable-wayland-ime"
    #       "--wayland-text-input-version=3"
    #
    #       # enable vaapi
    #       # "--enable-features=AcceleratedVideoDecodeLinuxGL"
    #       # "--enable-features=VaapiIgnoreDriverChecks"
    #
    #       # enable vulakn support
    #       # NOTE: enabling vulkan disable video play in wavve.com <2024-12-25>
    #       # "--enable-features=Vulkan"
    #     ];
    #     flagStr = builtins.concatStringsSep " " flags;
    #   in
    #   {
    #     text = ''
    #       [Desktop Entry]
    #       Version=1.0
    #       Name=Brave
    #       GenericName=Web Browser
    #       Comment=Access the Internet
    #       StartupNotify=true
    #       StartupWMClass=brave-browser
    #       Exec=flatpak run --branch=stable --command=brave --file-forwarding com.brave.Browser ${flagStr} @@u %U @@
    #       Terminal=false
    #       Icon=com.brave.Browser
    #       Type=Application
    #       Categories=Network;WebBrowser;
    #       MimeType=application/xhtml+xml;application/xhtml_xml;application/xml;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;
    #       Actions=new-window;new-private-window;new-tor-window;
    #       X-Flatpak=com.brave.Browser
    #
    #       [Desktop Action new-window]
    #       Name=New Window
    #       Exec=flatpak run --branch=stable --command=brave com.brave.Browser ${flagStr}
    #
    #       [Desktop Action new-private-window]
    #       Name=New Private Window
    #       Exec=flatpak run --branch=stable --command=brave com.brave.Browser ${flagStr} --incognito
    #     '';
    #   };
  };
}
