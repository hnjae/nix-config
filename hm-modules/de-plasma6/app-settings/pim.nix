{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/kpeople";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kpeoplevcard";
      mode = "755";
      type = "dir";
    }
  ];
}
