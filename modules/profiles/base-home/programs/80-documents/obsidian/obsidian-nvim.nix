{
  lib,
  pkgs,
  config,
  ...
}:

let
  baseHomeCfg = config.base-home;

  appId = "obsidian-nvim";
  # icon = "${pkgs.pantheon.elementary-icon-theme}/share/icons/elementary/apps/128/utilities-system-monitor.svg";

  # icon = "${pkgs.whitesur-icon-theme}/share/icons/WhiteSur/apps/scalable/accessories-notes.svg";
  icon = "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/org.standardnotes.standardnotes.svg";
  iconPkg = pkgs.runCommandLocal appId { } ''
    mkdir -p "$out/share/icons/hicolor/scalable/apps/"

    cp --reflink=auto \
      "${icon}" \
      "$out/share/icons/hicolor/scalable/apps/${appId}.svg"

    paths=(
      "$out/share/icons/hicolor/512x512/apps/"
      "$out/share/icons/hicolor/256x256/apps/"
      "$out/share/icons/hicolor/128x128/apps/"
      "$out/share/icons/hicolor/64x64/apps/"
      "$out/share/icons/hicolor/48x48/apps/"
      "$out/share/icons/hicolor/32x32/apps/"
      "$out/share/icons/hicolor/16x16/apps/"
    )
    for path in "''${paths[@]}"; do
      mkdir -p "''$path"
      ln -s \
        "$out/share/icons/hicolor/scalable/apps/${appId}.svg" \
        "''${path}/${appId}.svg"
    done
  '';
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.isLinux) {
    home.packages = [ iconPkg ];

    home.shellAliases = {
      so = ''cd "''${XDG_DOCUMENTS_DIR:-''${HOME}/Documents}/obsidian/home"'';
      et = ''vi "''${XDG_DOCUMENTS_DIR:-''${HOME}/Documents}/obsidian/home/dailies/$(date '+%Y-%m-%d').md"'';
      ew = ''vi "''${XDG_DOCUMENTS_DIR:-''${HOME}/Documents}/obsidian/home/weeklies/$(date '+%G-W%V').md"'';
    };

    xdg.desktopEntries."obsidian-nvim" = lib.mkIf (pkgs.stdenv.isLinux && baseHomeCfg.isDesktop) (
      let
        appId = "obsidian-nvim";
      in
      {
        name = appId;
        comment = "w. custom .desktop entry";
        exec = "${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title obsidian -e nvim ${config.xdg.userDirs.documents}/obsidian/home/index.md";
        terminal = false;
        inherit icon;
        type = "Application";
        startupNotify = false;
        categories = [
          "Office"
        ];
      }
    );
  };

}
