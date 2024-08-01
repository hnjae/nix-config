{...}: {
  programs.plasma.configFile."krunnerrc" = {
    "Plugins"."baloosearchEnabled".value = true;
  };
  programs.plasma.configFile."baloofilerc" = {
    "General" = {
      "only basic indexing".value = true; # only index file names only
      "exclude folders" = {
        shellExpand = true;
        value = builtins.concatStringsSep "," [
          "$HOME/git/"
          "$HOME/Pictures/"
          "$HOME/Projects/"
          "$HOME/Library/"
          "$HOME/Music/"
          "$HOME/Zotero/"
        ];
      };
    };
  };
}
