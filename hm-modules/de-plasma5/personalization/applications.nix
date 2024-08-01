{...}: {
  # Personalization - Applications - Default Applications
  programs.plasma.configFile."kdeglobals"."General" = {
    "TerminalApplication".value = "alacritty";
    "TerminalService".value = "Alacritty.desktop";
    "BrowserApplication".value = "firefox.desktop";
  };

  # allow xwayland apps to read keys with modifiers (for global hot keys)
  programs.plasma.configFile."kwinrc"."Xwayland"."XwaylandEavesdrops".value = "Combinations";
}
