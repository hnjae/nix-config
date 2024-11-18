{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/kmenuedit";
      mode = "755";
      type = "dir";
    }
  ];
}
