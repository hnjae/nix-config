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
  '';
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [
      iconPkg
      (pkgs.makeDesktopItem {
        genericName = "Obsidian Nvim";
        name = appId;
        desktopName = appId;
        categories = [ "Office" ];
        # exec = "${pkgs.foot}/bin/foot --app-id-${appId} --title=${appId} -e nvim ${config.xdg.userDirs.documents}/obsidian/home/index.md";
        # exec = "${pkgs.alacritty}/bin/alacritty --class ${appId},${appId} --title obsidian -e nvim ${config.xdg.userDirs.documents}/obsidian/home/index.md";
        # exec = "${pkgs.kitty}/bin/kitty --app-id=${appId} --os-window-tag=${appId} --title=${appId} --working-directory=${config.xdg.userDirs.documents}/obsidian/home -e nvim .";
        exec = "${pkgs.wezterm}/bin/wezterm start --class=${appId} --cwd=${config.xdg.userDirs.documents}/obsidian/home -e nvim .";
        icon = appId;
      })
    ];
  };
}
