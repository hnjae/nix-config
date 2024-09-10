{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.ww-run-raise.packages.${pkgs.stdenv.system}.default
  ];
  # disable dolphin launch
  programs.plasma.shortcuts."services/org.kde.dolphin.desktop"."_launch" = [];

  xdg.desktopEntries."ww-pkm" = {
    name = "ww-pkm";
    exec = "ww -pn Logseq -fc Logseq -d com.logseq.Logseq";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-pkm.desktop"."_launch" = "Meta+I";

  xdg.desktopEntries."ww-browser" = {
    name = "ww-browser";
    exec = "ww -pn brave -fc brave-browser -d brave-browser";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-browser.desktop"."_launch" = "Meta+N";

  xdg.desktopEntries."ww-terminal" = {
    name = "ww-brave";
    exec = "ww -pn konsole -fc org.kde.konsole -d org.kde.konsole";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-terminal.desktop"."_launch" = "Meta+E";
}
