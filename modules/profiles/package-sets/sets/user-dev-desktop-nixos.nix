{ lib, ... }:
pkgs:
let
  inherit (pkgs.config) allowUnfree;
in
lib.flatten [
  pkgs.unstable.zed-editor-fhs

  (lib.lists.optionals allowUnfree [
    pkgs.unstable.jetbrains.idea
    pkgs.unstable.vscode-fhs
  ])
]
