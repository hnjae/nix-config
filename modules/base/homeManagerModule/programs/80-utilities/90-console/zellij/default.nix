{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  programs.zellij = {
    enable = true;

    # these options autostarts zellij
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  xdg.configFile."zellij/config.kdl".text = lib.concatLines [
    (builtins.readFile ./resources/configs/configs.kdl/ui.kdl)
    (builtins.readFile ./resources/configs/configs.kdl/others.kdl)
    (if (baseHomeCfg.base24.enable) then ''theme "base24"'' else ''theme "ansi"'')
    (builtins.readFile ./resources/configs/configs.kdl/keybinds.kdl)
  ];

  xdg.configFile."zellij/layouts".source = ./resources/configs/layouts;
  xdg.configFile."zellij/themes/ansi.kdl".source = ./resources/configs/themes/ansi.kdl;
  xdg.configFile."zellij/themes/base24.kdl" = lib.mkIf baseHomeCfg.base24.enable {
    source = config.scheme {
      templateRepo = ./resources/base24-zellij;
      target = "default";
    };
  };

  programs.zsh.initExtra = builtins.readFile ./resources/zsh-chpwd.zsh;
  programs.fish.interactiveShellInit = builtins.readFile ./resources/fish-chpwd.fish;

  home.shellAliases = {
    z = "zellij";
  };
}
