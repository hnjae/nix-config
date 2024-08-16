{config, ...}: {
  stateful.nocowNodes = [
    {
      path = "${config.xdg.dataHome}/baloo";
      mode = "755";
      type = "dir";
    }
  ];
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/baloofilerc";
      mode = "644";
      type = "file";
    }
  ];
}
