/*
  NOTE:
  - Logseq 의 flatpak version 에서 `filesystems=home` 을 허락하는 것이 기본 값. <2025-03-21>
  - Logesq 은 현재 electron 31.7.5 을 사용하고 있으며, 이는 text-input-v3 를 아직 지원하지 않는다. <2025-02-04>

  - electron 33+ 를 사용해야 text-input-v3 가 지원이 됨.
*/
{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  appId = "com.logseq.Logseq";
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/Logseq";
        mode = "700";
        type = "dir";
      }
    ];

    default-app.fromApps = [ appId ];
    services.flatpak.packages = [ appId ];
    services.flatpak.overrides."${appId}" = {
      Context = {
        sockets = [ "!wayland" ];
        # for git support
        # filesystems = [
        #   "~/.ssh"
        #   "/run/current-system/sw/bin"
        # ];
      };
    };
  };
}
