{config, ...}: {
  stateful.cowNodes = [
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
      path = "${config.xdg.configHome}/kactivitymanagerd-switcher";
      mode = "600";
      type = "file";
    }
  ];
  stateful.nocowNodes = [
  ];
}
