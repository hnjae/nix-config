{
  pkgsUnstable,
  pkgs,
  lib,
  config,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (builtins) concatStringsSep;

  COLORFGBG = if ("light" == "light") then "0;15" else "15;0";
in
{
  config = lib.mkIf baseHomeCfg.isDesktop {
    home.packages = [ pkgsUnstable.neovide ];

    default-app.text = "neovide";

    xdg.desktopEntries."neovide" = lib.mkIf (pkgs.stdenv.isLinux) {
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
      categories = [
        "Utility"
        "TextEditor"
      ];
      settings = {
        Keywords = concatStringsSep ";" [
          "Text"
          "Editor"
        ];
      };
    };
  };
}
