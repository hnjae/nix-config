{
  config,
  pkgs,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  imports = [
    ./tmpfiles.nix
  ];

  default-app.enable = baseHomeCfg.isDesktop && isLinux;
  home.preferXdgDirectories = true;
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = isLinux && baseHomeCfg.isDesktop;
      createDirectories = true;
    };
  };
}
