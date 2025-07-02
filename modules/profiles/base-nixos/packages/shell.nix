{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableLsColors = false;
  };

  environment.shells = with pkgs; [
    bashInteractive
    dash
    fish
    # (lib.hiPrio (
    #   pkgs.makeDesktopItem {
    #     name = "fish";
    #     desktopName = "This should not be displayed.";
    #     exec = ":";
    #     noDisplay = true;
    #   }
    # ))
  ];
}
