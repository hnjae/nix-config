{config, ...}: {
  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/nix";
      mode = "755";
      type = "dir";
    }
    # --
    {
      path = "${config.xdg.configHome}/sops";
      mode = "700";
      type = "dir";
    }
    # --
    {
      path = "${config.xdg.dataHome}/systemd";
      mode = "755";
      type = "dir";
    }
  ];
}
