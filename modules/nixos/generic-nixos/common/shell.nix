{
  pkgs,
  lib,
  ...
}: {
  users.defaultUserShell = lib.mkOverride 999 pkgs.bashInteractive;

  programs.fish.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableLsColors = false;
  };
  programs.xonsh.enable = true;
  environment.shells = with pkgs; [
    nushell
    dash
    elvish
    bashInteractive
  ];
  # environment.systemPackages = with pkgs; [
  #   bashInteractive
  # ];
}
