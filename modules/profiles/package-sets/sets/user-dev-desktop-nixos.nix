{ lib, ... }:
pkgs:
lib.flatten [
  pkgs.unstable.jetbrains.idea-community
  pkgs.unstable.zed-editor-fhs
  pkgs.unstable.vscode-fhs
]
