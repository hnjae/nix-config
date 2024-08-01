{
  config,
  lib,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (lib.lists) optionals;
in {
  config = lib.mkIf (genericHomeCfg.isDesktop) {
    home.packages = builtins.concatLists [
      (optionals (pkgs.stdenv.isLinux && genericHomeCfg.installTestApps)
        (with pkgs; [
          # rustdesk
          virt-manager
          remmina
          virt-viewer
          gnome.vinagre
        ]))
    ];
  };
}
