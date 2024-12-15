{
  config,
  pkgs,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (pkgs.stdenv.isLinux && genericHomeCfg.isDesktop) {
    home.packages = [
      (pkgs.qimgv-git.override {
        mpv-unwrapped = (import ../mpv/package.nix) {inherit config pkgs;};
      })
    ];
    default-app.image = lib.mkDefault "qimgv";
  };
}
