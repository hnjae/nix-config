{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/plasma_calendar_astronomicalevents";
      mode = "600";
      type = "file";
    }
    # Manages by nix
    # {
    #   path = "${config.xdg.configHome}/plasma_calendar_holiday_regions";
    #   mode = "600";
    #   type = "file";
    # }
  ];
}
