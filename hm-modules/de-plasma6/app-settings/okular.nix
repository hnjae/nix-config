{config, ...}: {
  stateful.cowNodes = [
    {
      path = "${config.xdg.configHome}/okularrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/okularpartrc";
      mode = "600";
      type = "file";
    }
  ];
}
