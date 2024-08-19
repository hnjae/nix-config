{
  digitalClock = {
    date = {
      format = "isoDate";
      position = "besideTime";
    };
    calendar = {
      firstDayOfWeek = "monday";
      showWeekNumbers = true;
      plugins = [
        # "holidaysevents"
      ];
    };
    time.format = "24h";
    timeZone.format = "code";
  };
}
