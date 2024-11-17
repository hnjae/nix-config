/*
NOTE:  <2024-11-15>

Logesq 은 현재 electron 28 을 사용하고 있으며, 이는 text-input-v3 를 아직 지원하지 않는다.

electron 33+ 를 사용해야함.
*/
{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;

  appId = "com.logseq.Logseq";
  electronFlags = [
    "--ozone-platform-hint=auto"
    "--enable-features=UseOzonePlatform"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
  ];
in {
  config = lib.mkIf genericHomeCfg.isDesktop {
    services.flatpak.packages = [appId];

    default-app.fromApps = ["com.logseq.Logseq"];
    stateful.cowNodes = [
      {
        path = "${config.xdg.configHome}/Logseq";
        mode = "700";
        type = "dir";
      }
    ];

    services.flatpak.overrides."${appId}" = {
      # Environment = { "GTK_IM_MODULE" = "xim"; };
      Context = {
        # sockets = ["!x11"];
        sockets = ["!wayland"];
        # for git support
        # filesystems = [
        #   "~/.ssh"
        #   "/run/current-system/sw/bin"
        # ];
      };
    };
    # xdg.dataFile."applications/com.logseq.Logseq.desktop" = let
    #   flags = builtins.concatStringsSep " " electronFlags;
    # in {
    #   enable = true;
    #   text = ''
    #     [Desktop Entry]
    #     Name=Logseq Desktop
    #     Exec=flatpak run --branch=stable --arch=x86_64 --command=run.sh --file-forwarding com.logseq.Logseq @@u %U @@ ${flags}
    #     Terminal=false
    #     Type=Application
    #     Icon=com.logseq.Logseq
    #     StartupWMClass=Logseq
    #     Comment=Custom desktop entries.
    #     MimeType=x-scheme-handler/logseq;
    #     Categories=Utility;Office;
    #     NoDisplay=false
    #     X-Flatpak=com.logseq.Logseq
    #   '';
    # };
  };
}
