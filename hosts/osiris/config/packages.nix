{ pkgs, ... }:
{
  users.users.hnjae.packages = [
    pkgs.seafile-client
  ];

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
