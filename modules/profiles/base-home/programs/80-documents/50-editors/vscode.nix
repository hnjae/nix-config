{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  baseHomeCfg = config.base-home;
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.config.allowUnfree && baseHomeCfg.isDev) {
    home.packages = [ pkgsUnstable.vscode-fhs ];

    stateful.nodes = [
      {
        path = "${config.xdg.configHome}/Code";
        mode = "700";
        type = "dir";
      }
      {
        path = "${config.home.homeDirectory}/.vscode";
        mode = "755";
        type = "dir";
      }
    ];

    /*
      NOTE: 2025-03-24

        https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/editors/vscode/generic.nix#L120

        --wayland-text-input-version=3 이 NIXOS_OZONE_WL 플래그에 추가될때까지 임시로 추가함
    */
    xdg.dataFile."applications/code.desktop" = {
      text = ''
        [Desktop Entry]
        Actions=new-empty-window
        Categories=Utility;TextEditor;Development;IDE
        Comment=Code Editing. Redefined.
        Exec=code --wayland-text-input-version=3 %F
        GenericName=Text Editor
        Icon=vscode
        Keywords=vscode
        Name=Visual Studio Code
        StartupNotify=true
        StartupWMClass=Code
        Type=Application
        Version=1.4

        [Desktop Action new-empty-window]
        Exec=code --wayland-text-input-version=3 --new-window %F
        Icon=vscode
        Name=New Empty Window
      '';
    };

    xdg.dataFile."applications/code-url-handler.desktop" = {
      text = ''
        [Desktop Entry]
        Categories=Utility;TextEditor;Development;IDE
        Comment=Code Editing. Redefined.
        Exec=code --wayland-text-input-version=3 --open-url %U
        GenericName=Text Editor
        Icon=vscode
        Keywords=vscode
        MimeType=x-scheme-handler/vscode
        Name=Visual Studio Code - URL Handler
        NoDisplay=true
        StartupNotify=true
        StartupWMClass=Code
        Type=Application
        Version=1.4
      '';
    };
  };
}
