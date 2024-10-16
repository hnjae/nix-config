{...}: {
  # INFO: 석양의 색온도가 3000k
  # programs.plasma.configFile."kwinrc"."NightColor" = {
  #   "Active".value = true;
  #   "Mode".value = "Times";
  #   "TransitionTime".value = 20;
  #   "EveningBeginFixed".value = 1955;
  #   "MorningBeginFixed".value = 0500;
  #   "NightTemperature".value = 3500; # default 4500k
  # };

  programs.plasma.kwin.nightLight = {
    enable = false;
    mode = "constant";
    temperature.night = 3500;
    time = {
      morning = "05:00";
      evening = "20:00";
    };
    transitionTime = 60;
  };
}
