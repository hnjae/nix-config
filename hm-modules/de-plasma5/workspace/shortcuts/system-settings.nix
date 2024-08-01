{...}: {
  #--- Plasma
  programs.plasma.shortcuts."plasmashell" = {
    "show dashboard" = [];
    "next activity" = [];
    "previous activity" = [];
    "activate task manager entry 1" = [];
    "activate task manager entry 2" = [];
    "activate task manager entry 3" = [];
    "activate task manager entry 4" = [];
    "activate task manager entry 5" = [];
    "activate task manager entry 6" = [];
    "activate task manager entry 7" = [];
    "activate task manager entry 8" = [];
    "activate task manager entry 9" = [];
    "activate task manager entry 10" = [];
    "manage activities" = ["Meta+Q"]; # default: <M-q>
  };

  #--- Session Management
  # programs.plasma.shortcuts."ksmserver"."Lock Session" = "Screensaver";
  programs.plasma.shortcuts."ksmserver"."Lock Session" = ["Alt+I" "Alt+L" "Screensaver"];
  # Alt+I: Alt+L 의 colemak-dh

  #--- Keyboard Layout Switcher
  programs.plasma.shortcuts."KDE Keyboard Layout Switcher" = {
    "Switch keyboard layout to English (Colemak-DH)" = [];
    "Switch to Next Keyboard Layout" = [];
  };
}
