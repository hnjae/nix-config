/*
  ---
  date: 2026-01-10
  ---

  ## extraFiles 에서 `source` 가 아니라 `text 를 사용한 이유:

  `source` 를 사용하면, `dotfiles` 이 업데이트 되었을 때 무조건 derivation 이 업데이트 됨. (`ftplugin/<name>.lua` 가 바뀌지 않더라도.)
*/
{ inputs, ... }:
{ lib, ... }:
let
  inherit (inputs) dotfiles;

  ftpluginDir = "${dotfiles}/profiles/00-default/xdg-config/nvim/ftplugin";
  files = builtins.readDir ftpluginDir;
  luaFiles = lib.filterAttrs (
    path: filetype:
    (
      (builtins.elem filetype [
        "regular"
        "symlink"
      ])
      && (
        let
          length = builtins.stringLength path;
          last4Chars = builtins.substring (length - 4) length path;
        in
        builtins.elem last4Chars [
          ".lua"
          ".vim"
        ]
      )
    )
  ) files;
in
{
  extraFiles = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "ftplugin/${name}" {
      text = builtins.readFile "${ftpluginDir}/${name}";
    }
  ) luaFiles;
}
