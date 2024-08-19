{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/katevirc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/kateschemarc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.dataHome}/kate";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kwrite";
      mode = "755";
      type = "dir";
    }
  ];
}
