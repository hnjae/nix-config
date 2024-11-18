{config, ...}: {
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  stateful.nodes = [
    {
      path = "${config.xdg.dataHome}/direnv";
      mode = "700";
      type = "dir";
    }
  ];
}
