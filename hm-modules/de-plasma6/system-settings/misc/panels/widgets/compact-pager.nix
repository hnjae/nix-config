{
  # alternative of "org.kde.plasma.pager"
  name = "com.github.tilorenz.compact_pager";
  config = {
    General = {
      currentDesktopSelected = "ShowOverview";
      forceLayout = "Compact";
      enableScrolling = "false";
    };
    Appearance = {
      # font
      fontFamily = "Monospace";
      fontBold = "false";

      # border
      borderRadius = "15";
      displayBorder = "true";

      # color
      # activeBgColor="229,229,229";
      # borderColor=;
      sameBorderColorAsFont = "true";
    };
  };
}
