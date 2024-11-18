{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/kfontview";
      mode = "755";
      type = "dir";
    }
  ];
}
