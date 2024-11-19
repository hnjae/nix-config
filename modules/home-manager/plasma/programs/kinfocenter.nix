{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/kinfocenter";
      mode = "755";
      type = "dir";
    }
  ];
}
