{
  pkgsUnstable,
  pkgs,
  lib,
  config,
  ...
}: let
  genericHomeCfg = config.generic-home;
  inherit (builtins) concatStringsSep;

  COLORFGBG =
    if (config.base24.variant == "light")
    then "0;15"
    else "15;0";
in {
  home.packages = lib.mkIf genericHomeCfg.isDesktop [pkgsUnstable.neovide];

  default-app.text = "neovide";

  xdg.desktopEntries."neovide" = lib.mkIf (genericHomeCfg.isDesktop
    && pkgs.stdenv.isLinux
    && genericHomeCfg.base24.enable) {
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
}
