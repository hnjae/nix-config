_: {
  programs.plasma.configFile."krunnerrc" = {
    "Plugins"."krunner_appstreamEnabled" = false; # disable software center
    "Plugins/Favorites"."plugins" = "krunner_services";
  };
}
