{config, ...}: {
  stateful.nocowNodes = [
    {
      path = "${config.xdg.dataHome}/xdg-desktop-portal-kde/xdg-desktop-portal-kdestaterc";
      mode = "755";
      type = "file";
    }
  ];
}
