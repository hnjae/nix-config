{...}: let
  inherit (builtins) concatStringsSep map;
  wmclassMaker = classes: (concatStringsSep "|" (map (cls: "(" + cls + ")") classes));
  exception0 = {
    "BorderSize".value = 0;
    "Enabled".value = true;
    "ExceptionPattern".value = wmclassMaker [
      "ticktick"
      # "logseq"
    ];
    "ExceptionType".value = 0;
    "HideTitleBar".value = true;
    "Mask".value = 0;
  };
in {
  programs.plasma.configFile."breezerc" = {
    "Common"."OutlineCloseButton".value = false; # to match gtk
    "Windeco Exception 0" = exception0;
  };
  programs.plasma.configFile."lightlyrc" = {
    "Common"."OutlineCloseButton".value = false; # to match gtk
    "Windeco"."DrawBackgroundGradient".value = false;
    "Windeco Exception 0" = exception0;
  };
  programs.plasma.configFile."kwinrc"."org.kde.kdecoration2"."BorderSize".value = "Tiny";
}
