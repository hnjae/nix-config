{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = builtins.concatLists [
      (lib.lists.optional pkgs.stdenv.isLinux pkgs.alacritty)
      (lib.lists.optional pkgs.stdenv.isDarwin pkgsUnstable.alacritty)
    ];

    default-app.fromApps = [ "Alacritty" ];
  };
}
