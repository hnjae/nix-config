{
  pkgsUnstable,
  pkgs,
  lib,
  config,
  ...
}: let
  baseHomeCfg = config.base-home;
  inherit (builtins) concatStringsSep;

  COLORFGBG =
    if (config.base-home.base24.darkMode)
    then "15;0"
    else "0;15";
in {
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = [pkgsUnstable.neovide];

    default-app.text = "neovide";

    xdg.desktopEntries."neovide" = lib.mkIf (pkgs.stdenv.isLinux
      && baseHomeCfg.base24.enable) {
      type = "Application";
      name = "Neovide";
      comment = "custom desktop entry";
      exec = ''env COLORFGBG="${COLORFGBG}" neovide %F'';
      icon = "neovide";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      categories = ["Utility" "TextEditor"];
      settings = {Keywords = concatStringsSep ";" ["Text" "Editor"];};
    };
  };
}
