{
  config,
  lib,
  inputs,
  ...
}: let
  genericHomeCfg = config.generic-home;
  isBase24 = genericHomeCfg.base24.enable;
  # font = "MesloLGM Nerd Font";
  font = "monospace";

  colorscheme =
    if isBase24
    then "base24"
    else "Breeze";

  mkProfile = {
    command,
    name,
  }: (builtins.concatStringsSep "\n\n" [
    ''
      [Appearance]
      ColorScheme=${colorscheme}
      BoldIntense=false
      Font=${font},${
        toString genericHomeCfg.terminalFontSize
      },-1,5,50,0,0,0,0,0

      [General]
      ErrorBars=0
      Command=${command}
      Name=${name}
      TerminalColumns=85
      Environment=TERM=xterm-256color
      Parent=FALLBACK/

      [Scrolling]
      HistorySize=5000
      ScrollBarPosition=2
      HighlightScrolledLines=false

      [Interaction Options]
      AllowEscapedLinks=true
      OpenLinksByDirectClickEnabled=true
      CopyTextAsHTML=true
      TrimLeadingSpacesInSelectedText=true
      TrimTrailingSpacesInSelectedText=true
      UnderlineFilesEnabled=true

      [Terminal Features]
      ReverseUrlHints=false
    ''
    (''
        [Cursor Options]
        CursorShape=0
      ''
      + (builtins.readFile (lib.strings.optionalString isBase24
        (config.scheme {
          template = ''
            CustomCursorColor={{base05-rgb-r}},{{base05-rgb-g}},{{base05-rgb-b}}
            CustomCursorTextColor={{base00-rgb-r}},{{base00-rgb-g}},{{base00-rgb-b}}
            UseCustomCursorColor=true
          '';
        }))))
  ]);
in {
  stateful.nodes = [
    # stateful 하게 사용 안함.
    # {
    #   path = "${config.xdg.dataHome}/konsole";
    #   mode = "755";
    #   type = "dir";
    # }

    # 선언됨
    # {
    #   path = "${config.xdg.configHome}/konsolerc";
    #   mode = "600";
    #   type = "file";
    # }

    {
      path = "${config.xdg.configHome}/konsolesshconfig";
      mode = "600";
      type = "file";
    }
  ];

  xdg.dataFile."konsole/base24.colorscheme".source =
    lib.mkIf isBase24 (config.scheme {templateRepo = inputs.base24-konsole;});

  xdg.dataFile."konsole/bash.profile".text = mkProfile {
    name = "bash";
    command = "/usr/bin/env bash";
  };
  xdg.dataFile."konsole/fish.profile".text = mkProfile {
    name = "fish";
    command = "/usr/bin/env fish";
  };
  xdg.dataFile."konsole/zellij.profile".text = mkProfile {
    name = "zellij";
    command = "/usr/bin/env zellij";
  };
  xdg.dataFile."konsole/tmux.profile".text = mkProfile {
    name = "tmux";
    command = "/usr/bin/env tmux";
  };
  xdg.dataFile."konsole/zsh.profile".text = mkProfile {
    name = "zsh";
    command = "/usr/bin/env zsh";
  };

  programs.plasma.configFile."konsolerc" = {
    "Desktop Entry" = {DefaultProfile.value = "zsh.profile";};

    FileLocation = {
      # use `~/.cache/konsole` instead of `/tmp`
      scrollbackUseCacheLocation = true;
      scrollbackUseSystemLocation = false;
    };

    ThumbnailsSettings = {
      ThumbnailAlt = true;
    };

    General = {ConfigVersion.value = 1;};
    KonsoleWindow = {RememberWindowSize.value = false;};
    "MainWindow.Toolbar mainToolBar" = {Iconsize.value = 16;};
    "MainWindow.Toolbar sessionToolbar" = {
      Iconsize.value = 16;
      ToolButtonStyle.value = "IconOnly";
    };
    UiSettings = {ColosScheme.value = colorscheme;};
  };
}
