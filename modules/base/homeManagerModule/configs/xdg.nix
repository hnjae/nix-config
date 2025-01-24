{
  config,
  pkgs,
  ...
}: let
  baseHomeCfg = config.base-home;
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = pkgs.stdenv.isLinux && baseHomeCfg.isDesktop;
      createDirectories = true;
    };
  };
}
