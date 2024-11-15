{pkgs, ...}: {
  xdg.configFile.waybar = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/waybar;
  };
  xdg.configFile.rofi = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/rofi;
  };
  xdg.configFile.wofi = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/wofi;
  };
  xdg.configFile.mako = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/mako;
  };

  # for x11 windowmanager
  xdg.configFile.picom = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/picom;
  };
  xdg.configFile.jgmenu = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/jgmenu;
  };
  xdg.configFile.polybar = {
    recursive = true;
    source = ./dotfiles/xdg.configFile/polybar;
  };
  home.packages = with pkgs; [albert ulauncher rofi];
}
