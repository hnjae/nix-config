{...}: {
  programs.plasma.configFile."kwinrc" = {
    "Effect-mousemark"."Freedrawcontrol" = true;
    "Effect-mousemark"."Freedrawshift" = false;

    "Plugins" = {"mousemarkEnabled" = true;};
  };

  programs.plasma.shortcuts."kwin" = {
    ClearLastMouseMark = ["Meta+Ctrl+Del"];
    ClearMouseMarks = ["Meta+Shift+Ctrl+Del"];
  };
}
