{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.configHome}/kdeconnect";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/kdeconnect.daemon";
      mode = "755";
      type = "dir";
    }
  ];
}
