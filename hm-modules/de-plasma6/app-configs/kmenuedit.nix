{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/kmenuedit";
      mode = "755";
      type = "dir";
    }
  ];
}
