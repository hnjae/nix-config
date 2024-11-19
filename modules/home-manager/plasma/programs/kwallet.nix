{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/kwalletd";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.configHome}/kwalletmanager5rc";
      mode = "600";
      type = "dir";
    }
  ];
}
