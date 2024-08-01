{
  config,
  lib,
  ...
}: let
  genericHomeCfg = config.generic-home;
in {
  programs.zellij = {
    enable = true;
    # enableBashIntegration = true;
    # enableFishIntegration = true;
    # enableZshIntegration = true;
  };

  xdg.configFile."zellij/config.kdl".text = lib.concatLines [
    (builtins.readFile ./configs/configs.kdl/ui.kdl)
    (builtins.readFile ./configs/configs.kdl/keybinds.kdl)
    (builtins.readFile ./configs/configs.kdl/others.kdl)
    (
      if (genericHomeCfg.base24.enable)
      then ''theme "base24"''
      else ''theme "ansi"''
    )
  ];

  xdg.configFile."zellij/layouts".source = ./configs/layouts;
  xdg.configFile."zellij/themes/ansi.kdl".source = ./configs/themes/ansi.kdl;
  xdg.configFile."zellij/themes/base24.kdl" = lib.mkIf genericHomeCfg.base24.enable {
    source = config.scheme {
      templateRepo = ./base24-zellij;
      target = "default";
    };
  };

  programs.zsh.initExtra = builtins.readFile ./share/zsh-chpwd.zsh;
  programs.fish.interactiveShellInit =
    builtins.readFile ./share/fish-chpwd.fish;

  home.shellAliases = {z = "zellij";};
}
