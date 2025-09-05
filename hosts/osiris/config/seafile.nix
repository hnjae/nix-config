{ pkgs, ... }:
{
  users.users.hnjae.packages = [
    pkgs.seafile-client
  ];
}
