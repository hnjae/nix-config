{...}: {
  #--- Spectacle
  # programs.plasma.shortcuts."org.kde.spectacle.desktop" = {
  #   "ActiveWindowScreenShot" = "Meta+Print";
  #   "CurrentMonitorScreenShot" = [];
  #   "FullScreenScreenShot" = "Shift+Print";
  #   "OpenWithoutScreenshot" = [];
  #   "RectangularRegionScreenShot" = ["Meta+Shift+S" "Alt+Shift+R" "Meta+Shift+Print"];
  #   "WindowUnderCursorScreenShot" = "Meta+Ctrl+Print";
  #   "_launch" = "Print";
  # };
  programs.plasma.spectacle.shortcuts = {
    captureActiveWindow = "Meta+Print";
    captureCurrentMonitor = "Print";
    captureEntireDesktop = "Shift+Print";
    captureRectangularRegion = ["Meta+Shift+S" "Alt+Shift+R" "Meta+Shift+Print"];
    captureWindowUnderCursor = ["Meta+Ctrl+Print"];
    launch = ["Meta+S"];
    launchWithoutCapturing = ["Meta+Alt+S"];
  };
}
