{
  config,
  pkgs,
  self,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf (pkgs.stdenv.isLinux && genericHomeCfg.isDesktop) {
    home.packages = [
      (self.packages."${pkgs.stdenv.system}".qimgv-git.override
        {
          mpv-unwrapped = (import ../mpv/package.nix) {inherit config pkgs;};
        })
    ];
    default-app.image = "qimgv";
  };
}
