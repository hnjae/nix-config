{...}: {
  programs.plasma.shortcuts."kwin" =
    {
      "Window Close" = ["Alt+F4" "Meta+Shift+Q" "Meta+F4"];

      "Walk Through Windows" = "Meta+Tab";
      "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
      "Walk Through Windows of Current Application" = "Meta+`";
      "Walk Through Windows of Current Application (Reverse)" = "Meta+~";

      "Window Resize" = "Meta+R";

      "Switch to Desktop 1" = ["Meta+1"];
      "Switch to Desktop 2" = ["Meta+2"];
      "Switch to Desktop 3" = ["Meta+3"];
      "Switch to Desktop 4" = ["Meta+4"];
      "Switch to Desktop 5" = ["Meta+5"];
      "Switch to Desktop 6" = ["Meta+6"];
      "Switch to Desktop 7" = ["Meta+7"];
      "Switch to Desktop 8" = ["Meta+8"];
      "Switch to Desktop 9" = ["Meta+9"];

      "Window to Desktop 1" = ["Meta+!"];
      "Window to Desktop 2" = ["Meta+@"];
      "Window to Desktop 3" = ["Meta+#"];
      "Window to Desktop 4" = ["Meta+$"];
      "Window to Desktop 5" = ["Meta+%"];
      "Window to Desktop 6" = ["Meta+^"];
      "Window to Desktop 7" = ["Meta+&"];
      "Window to Desktop 8" = ["Meta+*"];
      "Window to Desktop 9" = ["Meta+("];

      "Window Minimize" = ["Meta+PgDown" "Meta+M"];

      # NOTE: you can not switch desktop via shortcut in overview mode (KDE X11 5.27)(available in wayland)
      "Overview" = ["Meta+W"];
      "ShowDesktopGrid" = ["Meta+G" "Meta+F8"];
      "ExposeAll" = [
        "Ctrl+F10"
        "Launch (C)"
        "Meta+Alt+W"
      ]; # Toggle Present Windows (All desktops)
      # "Expose" = ["Ctrl+F9" "Meta+W" ]; # Toggle Prensent Windows (Current desktop)
      # NOTE: Use Overview instead of Expose <2023-07-20>
      "Expose" = []; # Toggle Prensent Windows (Current desktop)

      ## Mouse Mark
      "ClearLastMouseMark" = "Meta+Shift+F12";
      "ClearMouseMarks" = "Meta+Shift+F11";
    }
    // (import ./config/non-polonium.nix);
}
