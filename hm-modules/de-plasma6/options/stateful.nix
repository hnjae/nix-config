{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/plasma_calendar_astronomicalevents";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/plasma_calendar_holiday_regions";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kactivitymanagerdrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kactivitymanagerd-pluginsrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kactivitymanagerd-statsrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kactivitymanagerd-switch";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kiorc";
      mode = "644";
      type = "file";
    }
  ];
  stateful.nocowNodes = [
  ];
}
