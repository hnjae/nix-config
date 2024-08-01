{...}: {
  # ~/.config/kglobalshortcutsrc

  # kwin
  programs.plasma.shortcuts."kwin" = {
    "Show Desktop" = ["Meta+D" "Ctrl+Alt+D"];

    # Window Management
    "Window Close" = ["Alt+F4" "Meta+Shift+Q"]; # defaults: "Alt+F4"
    "Window Resize" = ["Alt+F8" "Meta+R"]; # defaults: None
    "Window Maximize" = ["Alt+F10" "Meta+Up"]; # defaults: Meta+PgUp
    "Window Minimize" = ["Meta+M"]; # defaults: Meta+PgDown
    "Window Move" = ["Alt+F7"];
    "Window Move Center" = ["Alt+Shift+F7"];

    "Window Quick Tile Bottom" = [];
    "Window Quick Tile Bottom Left" = [];
    "Window Quick Tile Bottom Right" = [];
    "Window Quick Tile Left" = "Meta+Left";
    "Window Quick Tile Right" = "Meta+Right";
    "Window Quick Tile Top" = [];
    "Window Quick Tile Top Left" = [];
    "Window Quick Tile Top Right" = [];

    # Virtual Desktop
    "Switch to Desktop 1" = ["Meta+F1"];
    "Switch to Desktop 2" = ["Meta+F2"];
    "Switch to Desktop 3" = ["Meta+F3"];
    "Switch to Desktop 4" = ["Meta+F4"];
    "Window to Desktop 1" = ["Meta+Shift+F1"];
    "Window to Desktop 2" = ["Meta+Shift+F2"];
    "Window to Desktop 3" = ["Meta+Shift+F3"];
    "Window to Desktop 4" = ["Meta+Shift+F4"];

    "Switch One Desktop Down" = [];
    "Switch One Desktop Up" = [];
    "Switch One Desktop to the Left" = ["Meta+PgUp" "Ctrl+Alt+Left"]; # default: "Meta+Ctrl+Left"
    "Switch One Desktop to the Right" = ["Meta+PgDown" "Ctrl+Alt+Right"];
    "Window to Previous Desktop" = ["Ctrl+Alt+Shift+Left" "Meta+Shift+PgDown"];
    "Window to Next Desktop" = ["Meta+Shift+PgUp" "Ctrl+Alt+Shift+Right"];

    # Toggle Present Windows (순서대로: All, Current, Window)
    # 기본 단축키: `Ctrl+F키` 사용
    "Expose" = ["Alt+F1" "Meta+S"]; # Ctrl+F9
    "ExposeAll" = ["Launch (C)" "Meta+Alt+A"]; # Ctrl+F4
    "ExposeClass" = ["Meta+A"]; # Ctrl+F5
  };

  # Plasmashell
  programs.plasma.shortcuts."plasmashell" = {
    # kwin."Show Desktop" 과 동일 기능 수행.
    "show dashboard" = [];
  };
}
