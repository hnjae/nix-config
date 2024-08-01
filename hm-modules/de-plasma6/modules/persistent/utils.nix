{username}: let
  inherit (builtins) concatLists attrValues mapAttrs map;
in {
  # NOTE:  <2024-01-29>
  # mode2Dirs example:
  # nocowDirs = {
  #   "700" = [
  #     ".local/share/zathura"
  #   ];
  #   "755" = [
  #     ".local/share/baloo"
  #     ".local/share/zoxide"
  #   ];
  # };

  createTmpfiles = isDir: savePath: mode2Dirs: (concatLists (attrValues (mapAttrs (mode: dirs: (map (dir: "${
      if isDir
      then "d"
      else "f"
    } ${savePath}/${dir} ${mode} ${username} users")
    dirs))
  mode2Dirs)));

  createPersistDirs = mode2Dirs: (concatLists (attrValues (mapAttrs (_: dirs: (map (dir: {
      directory = dir;
      method = "symlink";
    })
    dirs))
  mode2Dirs)));

  createPersistFiles = mode2Files: (concatLists (attrValues mode2Files));
  # createPersistFiles = mode2Files: (concatLists (
  #   attrValues (
  #     mapAttrs
  #     (_: files: (
  #       map
  #       (file: {
  #         file = file;
  #         method = "symlink";
  #       })
  #       files
  #     ))
  #     mode2Files
  #   )
  # ));
}
