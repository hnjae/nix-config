{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/baloo";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.configHome}/baloofilerc";
      mode = "644";
      type = "file";
    }
  ];
}
