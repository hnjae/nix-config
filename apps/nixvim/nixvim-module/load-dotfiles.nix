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
  nvimConfigSrc = "${inputs.dotfiles}/profiles/00-default/xdg-config/nvim";

  mkDotfileLoader =
    {
      type,
      fileFilter, # input: basename, output: boolean
      recursive ? false,
    }:
    { lib, ... }:
    let

      # name: relative path from configDir (e.g. ftplugin/sh.lua)
      # value: nix-store path
      configFiles =
        if recursive then
          let
            # allFiles: list of absolute path
            allFiles = lib.filesystem.listFilesRecursive "${nvimConfigSrc}/${type}";
            filtered = builtins.filter (path: fileFilter (baseNameOf path)) allFiles;
          in
          builtins.listToAttrs (
            map (filtered: {
              name = lib.removePrefix "${nvimConfigSrc}" filtered;
              value = filtered;
            }) filtered
          )
        else
          let
            entries = lib.filterAttrs (
              basename: filetype:
              (builtins.elem filetype [
                "regular"
                "symlink"
              ])
              && (fileFilter basename)
            ) (builtins.readDir "${nvimConfigSrc}/${type}");
          in
          lib.mapAttrs' (
            basename: _: (lib.nameValuePair "${type}/${basename}" "${nvimConfigSrc}/${type}/${basename}")
          ) entries;
    in
    {
      extraFiles = lib.mapAttrs' (
        relPath: nixStorePath:
        lib.nameValuePair "${relPath}" {
          text = builtins.readFile nixStorePath;
        }
      ) configFiles;
    };

  hasLuaOrVimExt =
    path:
    let
      length = builtins.stringLength path;
      last4Chars = builtins.substring (length - 4) length path;
    in
    builtins.elem last4Chars [
      ".lua"
      ".vim"
    ];
in
{
  imports = [
    (mkDotfileLoader {
      type = "ftdetect";
      fileFilter = hasLuaOrVimExt;
    })
    (mkDotfileLoader {
      type = "ftplugin";
      fileFilter = hasLuaOrVimExt;
    })
    (mkDotfileLoader {
      type = "spell";
      fileFilter = lib.hasSuffix ".add";
    })
    (mkDotfileLoader {
      type = "syntax";
      fileFilter = hasLuaOrVimExt;
    })
  ];
}
