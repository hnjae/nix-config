{config, ...}: {
  programs.plasma.configFile."dolphinrc" = {
    "General" = {
      "FilterBar".value = true;
      "ShowFullPath".value = true;
      "GlobalViewProps".value = true; # use common display style for all folders
    };
    "CompactMode" = {
      "MaximumTextWidthIndex".value = 3; # Large
      "UseSystemFont" = false;
      "ViewFont" = "Monospace,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    };
    "DetailsMode" = {
      "UseSystemFont" = false;
      "ViewFont" = "Monospace,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    };
    "PreviewSettings"."Plugins".value = builtins.concatStringsSep "," [
      "appimagethumbnail"
      "audiothumbnail"
      "blenderthumbnail"
      "comicbookthumbnail"
      "cursorthumbnail"
      "djvuthumbnail"
      "ebookthumbnail"
      "exrthumbnail"
      "directorythumbnail"
      "fontthumbnail"
      "imagethumbnail"
      "jpegthumbnail"
      "kraorathumbnail"
      "windowsexethumbnail"
      "windowsimagethumbnail"
      "mobithumbnail"
      "opendocumentthumbnail"
      "gsthumbnail"
      "rawthumbnail"
      "svgthumbnail"
      "textthumbnail"
      "ffmpegthumbs"
    ];
  };
  stateful.cowNodes = [
    # ".config/dolphinrc" # 덮어쓰기 됨.
    # {
    #   path = "${config.xdg.configHome}/dolphinrc";
    #   mode = "600";
    #   type = "file";
    # }
    {
      path = "${config.xdg.configHome}/trashrc";
      mode = "600";
      type = "file";
    }
    {
      path = "${config.xdg.configHome}/ktrashrc";
      mode = "600";
      type = "file";
    }
  ];
}
