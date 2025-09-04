{ pkgs, ... }:
{
  environment.defaultPackages = [
    pkgs.seafile-client
  ];
}
