{config, ...}: {
  programs.plasma.configFile."krunnerrc" = {
    "General"."FreeFloating".value = true;
  };

  stateful.nodes = [
    # stateless
    # {
    #   path = "${config.xdg.configHome}/krunnerrc";
    #   mode = "644";
    #   type = "file";
    # }
  ];
}
