{
  config,
  pkgs,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = pkgs.stdenv.isLinux && genericHomeCfg.isDesktop;
      createDirectories = true;
    };
  };
}
