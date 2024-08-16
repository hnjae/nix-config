{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/kinfocenter";
      mode = "755";
      type = "dir";
    }
  ];
}
