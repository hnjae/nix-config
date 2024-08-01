{
  pkgs,
  lib,
  ...
}: {
  users.defaultUserShell = lib.mkOverride 999 pkgs.bashInteractive;
}
