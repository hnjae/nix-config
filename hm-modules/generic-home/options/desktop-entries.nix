{
  pkgs,
  lib,
  ...
}: {
  xdg.desktopEntries = lib.mkIf (!pkgs.stdenv.isLinux) (lib.mkForce {});
}
