{...}: {
  programs.plasma.shortcuts."kwin" = {
    "Walk Through Windows" = ["Meta+Tab"];
    "Walk Through Windows (Reverse)" = ["Meta+Shift+Tab"];
    "Walk Through Windows of Current Application" = ["Meta+`"];
    "Walk Through Windows of Current Application (Reverse)" = ["Meta+~"];

    "Walk Through Windows Alternative" = ["Alt+Tab"];
    "Walk Through Windows Alternative (Reverse)" = ["Alt+Shift+Tab"];
    "Walk Through Windows of Current Application Alternative" = ["Alt+`"];
    "Walk Through Windows of Current Application Alternative (Reverse)" = ["Alt+~"];
  };

  # do not show selected windows
  programs.plasma.configFile."kwinrc" = {
    "Plugins"."highlightwindowEnabled" = false;
    "TabBox"."HighlightWindows" = false;
    "TabBoxAlternative"."HighlightWindows" = false;
  };
}
