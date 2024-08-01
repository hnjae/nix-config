{pkgs, ...}: {
  programs.fish.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableLsColors = false;
  };
  programs.xonsh.enable = true;
  environment.shells = with pkgs; [
    nushellFull
    dash
    elvish
    bashInteractive
  ];
  # environment.systemPackages = with pkgs; [
  #   bashInteractive
  # ];
}
