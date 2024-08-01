{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.dataHome}/plasma_notes";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/plasma_icons";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/plasma";
      mode = "755";
      type = "dir";
    }
    {
      path = "${config.xdg.dataHome}/plasma-interactiveconsole";
      mode = "755";
      type = "dir";
    }
  ];
}
