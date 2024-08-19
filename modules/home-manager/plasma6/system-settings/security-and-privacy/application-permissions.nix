{...}: {
  # legacy x11 app support
  programs.plasma.configFile."kwinrc"."Xwayland"."XwaylandEavesdrops".value = "Combinations";
}
