{...}: {
  programs.plasma.configFile."krunnerrc"."General" = {
    "FreeFloating".value = true;
  };
}
