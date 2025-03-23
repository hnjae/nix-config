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

  # appId = "com.logseq.Logseq";

  package =
    (pkgs.logseq.override {
      electron_27 = pkgs.electron_33;
    }).overrideAttrs
      {
        # to add --enable-wayland-ime --wayland-text-input-version=3 <2025-03-21>
        postFixup = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
          # set the env "LOCAL_GIT_DIRECTORY" for dugite so that we can use the git in nixpkgs
          makeWrapper ${pkgs.electron_33}/bin/electron $out/bin/logseq \
            --set "LOCAL_GIT_DIRECTORY" ${pkgs.git} \
            --add-flags $out/share/logseq/resources/app \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime --wayland-text-input-version=3}}"
        '';
      };

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

    home.packages = [
      package
      pkgs.glibc # https://github.com/logseq/logseq/issues/10851
    ];

    # default-app.fromApps = [ appId ];
    # services.flatpak.packages = [ appId ];
    # services.flatpak.overrides."${appId}" = {
    #   Context = {
    #     sockets = [ "!wayland" ];
    #     # for git support
    #     # filesystems = [
    #     #   "~/.ssh"
    #     #   "/run/current-system/sw/bin"
    #     # ];
    #   };
    # };
  };
}
