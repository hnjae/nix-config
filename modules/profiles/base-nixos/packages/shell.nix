{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableLsColors = false;
  };

  environment.systemPackages = [
    pkgs.bashInteractive
    pkgs.dash

    pkgs.fish
    (lib.hiPrio (
      pkgs.makeDesktopItem {
        name = "fish";
        desktopName = "This should not be displayed.";
        exec = ":";
        noDisplay = true;
      }
    ))
  ];
}
