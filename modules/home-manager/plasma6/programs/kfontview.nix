{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/kfontview";
      mode = "755";
      type = "dir";
    }
  ];
}
