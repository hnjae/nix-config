{...}: let
  # Run plasma-apply-desktoptheme --list-themes for valid options.
  themes = {
    fluent-round = "Fluent-round";
    graphite = "Graphite";
  };

  # Run plasma-apply-cursortheme --list-themes for valid options.
  cursorThemes = {
    breeze-snow = "Breeze_Snow";
    bibata-modern-ice = "Bibata-Modern-Ice";
    googledot-white = "GoogleDot-White";
  };
in {
  programs.plasma.workspace.theme = themes.fluent-round;

  programs.plasma.workspace.cursorTheme = cursorThemes.breeze-snow;
}
