/*
  NOTE: <2025-02-04>

  Logesq 은 현재 electron 31.7.5 을 사용하고 있으며, 이는 text-input-v3 를 아직 지원하지 않는다.

  electron 33+ 를 사용해야한다.
*/
{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  appId = "com.logseq.Logseq";
  electronFlags = [
    "--ozone-platform-hint=auto"
    "--enable-features=UseOzonePlatform"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
  ];
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {
    services.flatpak.packages = [ appId ];

    default-app.fromApps = [ "com.logseq.Logseq" ];
    stateful.nodes = [
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
        sockets = [ "!wayland" ];
        # for git support
        # filesystems = [
        #   "~/.ssh"
        #   "/run/current-system/sw/bin"
        # ];
      };
    };
    xdg.dataFile."applications/com.logseq.Logseq.desktop" =
      # flags = builtins.concatStringsSep " " electronFlags;
      # Exec=flatpak run --branch=stable --arch=x86_64 --command=run.sh --file-forwarding com.logseq.Logseq @@u %U @@ ${flags}
      {
        enable = false;
        text = ''
          [Desktop Entry]
          Name=Logseq Desktop
          Exec=env GTK_IM_MODULE=xim flatpak run --branch=stable --command=run.sh --file-forwarding com.logseq.Logseq @@u %U @@
          Terminal=false
          Type=Application
          Icon=com.logseq.Logseq
          StartupWMClass=Logseq
          Comment=A privacy-first, open-source platform for knowledge management and collaboration.
          MimeType=x-scheme-handler/logseq;
          Categories=Utility;Office;
          NoDisplay=false
          X-Flatpak=com.logseq.Logseq
        '';
      };
  };
}
