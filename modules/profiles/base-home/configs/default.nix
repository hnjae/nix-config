{
  config,
  pkgs,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  imports = [
    ./tmpfiles.nix
  ];

  default-app.enable = baseHomeCfg.isDesktop && pkgs.stdenv.isLinux;
  home.preferXdgDirectories = true;
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = pkgs.stdenv.isLinux && baseHomeCfg.isDesktop;
      createDirectories = true;
    };
  };
}
