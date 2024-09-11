{
  inputs,
  pkgs,
  ...
}: {
  # 참고: https://colemakmods.github.io/mod-dh/gfx/compare/keyboard_calc_std_ergonomic_scores.png

  home.packages = [
    inputs.ww-run-raise.packages.${pkgs.stdenv.system}.default
  ];
  # disable dolphin launch
  programs.plasma.shortcuts."services/org.kde.dolphin.desktop"."_launch" = [];

  xdg.desktopEntries."ww-terminal" = {
    name = "ww-terminal";
    exec = "ww -pn konsole -fc org.kde.konsole -d org.kde.konsole";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-terminal.desktop"."_launch" = "Meta+N";

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
  programs.plasma.shortcuts."services/ww-browser.desktop"."_launch" = "Meta+E";

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

  xdg.desktopEntries."ww-ai" = {
    name = "ww-ai";
    exec = "ww -pn chromium -fc chrome-lobe.hjae.xyz__-Default -d chrome-lobe.hjae.xyz__-Default";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-ai.desktop"."_launch" = "Meta+O";

  xdg.desktopEntries."ww-todo" = {
    name = "ww-todo";
    exec = "ww -pn brave -fc brave-ticktick.com__webapp-Default -d brave-ticktick.com__webapp-Default";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-todo.desktop"."_launch" = "Meta+H";

  xdg.desktopEntries."ww-calendar" = {
    name = "ww-calendar";
    exec = "ww -pn chromium -fc chrome-calendar.notion.so__-Default -d applications:chrome-calendar.notion.so__-Default";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-calendar.desktop"."_launch" = "Meta+U";

  xdg.desktopEntries."ww-mail" = {
    name = "ww-mail";
    exec = "ww -pn thunderbird -fc org.mozilla.Thunderbird -d org.mozilla.Thunderbird";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-mail.desktop"."_launch" = "Meta+L";

  xdg.desktopEntries."ww-password" = {
    name = "ww-password";
    exec = "ww -pn 1password -fc 1Password -d 1password.desktop";
    type = "Application";
    noDisplay = true;
    startupNotify = false;
    settings = {
      "X-KDE-GlobalAccel-CommandShortcut" = "true";
    };
  };
  programs.plasma.shortcuts."services/ww-password.desktop"."_launch" = "Meta+K";
}
