{
  pkgs,
  lib,
  ...
}: {
  # users.defaultUserShell = lib.mkOverride 999 pkgs.bashInteractive;
  users.defaultUserShell = lib.mkOverride 999 pkgs.fish;
}
