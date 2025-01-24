{ pkgs, ... }:
{
  programs.fish.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableLsColors = false;
  };

  # programs.xonsh.enable = true;

  environment.shells = with pkgs; [
    # elvish
    # nushell
    bashInteractive
    dash
  ];

  # environment.systemPackages = with pkgs; [
  #   bashInteractive
  # ];
}
