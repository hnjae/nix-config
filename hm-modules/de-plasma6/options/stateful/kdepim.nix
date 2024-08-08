{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/apps/korganizer";
      mode = "755";
      type = "dir";
    }
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
  ];
}
