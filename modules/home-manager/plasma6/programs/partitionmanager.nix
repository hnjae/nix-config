{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/partitionmanager";
      mode = "755";
      type = "dir";
    }
  ];
}
