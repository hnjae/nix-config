{
  config,
  lib,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in {
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    home.packages = builtins.concatLists [
      (optionals (pkgs.stdenv.isLinux && baseHomeCfg.installTestApps)
        (with pkgs; [
          # rustdesk
          virt-manager
          remmina
          virt-viewer
          # vinagre # removed in nixos-24.11 use, remmina or gnome-connections
        ]))
    ];
  };
}
