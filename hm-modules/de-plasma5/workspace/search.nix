{...}: {
  #--- File Search
  programs.plasma.configFile."baloofilerc"."General"."only basic indexing".value =
    true;

  #--- Plasma Search
  programs.plasma.configFile."krunnerrc"."Plugins" = {
    "baloosearchEnabled".value = false;
    "recentdocumentsEnabled".value = false;
    "shellEnabled".value = false;
    "appstreamEnabled".value = false;
    "katesessionsEnabled".value = false;
    "konsoleprofilesEnabled".value = false;
  };
}
