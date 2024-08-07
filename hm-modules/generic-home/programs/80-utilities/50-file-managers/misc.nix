{
  pkgs,
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  home.packages =
    lib.lists.optionals genericHomeCfg.installTestApps
    (builtins.concatLists [
      (with pkgsUnstable; [
        # vifm
        # xplr
        felix-fx
        # xplorer # gui
      ])
    ]);
}
