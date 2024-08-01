{...}: {
  programs.plasma.configFile."kwinrc" = {
    "NightColor" = {
      "Active".value = true;
      "NightTemperature".value = 5200;
      "Mode".value = "Times";
      "MorningBeginFixed".value = 400;
      "EveningBeginFixed".value = 1900;
      "TransitionTime".value = 31;
    };

    # prefer smoother animations
    "Compositing"."LatencyPolicy".value = "High";
  };
}
