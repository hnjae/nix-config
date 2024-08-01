# https://github.com/nix-community/impermanence
# Stateful 하게 관리할 파일들.
# WIP
{
  lib,
  config,
  ...
}: let
  cfg = config.stateful;

  inherit (lib) mkOption types;
  inherit (builtins) throw;
  inherit (config.home) homeDirectory username;

  nodeType = lib.types.submodule {
    options = {
      path = mkOption {type = types.str;};
      mode = mkOption {type = types.str;};
      type = mkOption {type = types.enum ["dir" "file"];};
    };
  };
in {
  options.stateful = {
    enable = lib.mkEnableOption "";
    cowPath = mkOption {
      type = types.str;
      default = "${homeDirectory}/.persist/@cow";
    };
    nocowPath = mkOption {
      type = types.str;
      default = "${homeDirectory}/.persist/@nocow";
    };
    cowNodes = mkOption {
      type = types.listOf nodeType;
      default = [];
    };
    nocowNodes = mkOption {
      type = types.listOf nodeType;
      default = [];
    };
  };

  config = lib.mkIf (cfg.enable) (let
    inherit (builtins) substring stringLength;
    getPersistencePath = node: (let
      relPathFromHome =
        lib.path.removePrefix (/. + homeDirectory) (/. + node.path);
    in (
      if ((substring 0 2 relPathFromHome) == "./")
      then (substring 2 ((stringLength relPathFromHome) - 2) relPathFromHome)
      else
        (throw
          "The following value is not in the format expected: ${relPathFromHome}")
    ));

    # lib.zipLists, lib.lists.commonPrefix
    # getRelPathFromHome = path: (
    #   let
    #     home = lib.splitString "/" config.home.homeDirectory;
    #     homeLength = lib.length home;
    #     target = lib.splitString "/" path;
    #   in (builtins.concatStringsSep "/" (
    #     lib.sublist homeLength ((lib.length target) - 4) target
    #   ))
    # );
    # getPersistencePath = node: (getRelPathFromHome node.path);

    nodes2filePersistence = nodes: (map (node: (getPersistencePath node))
      (builtins.filter (node: (node.type == "file")) nodes));
    nodes2dirPersistence = nodes: (map (node: {
      directory = getPersistencePath node;
      method = "symlink";
    }) (builtins.filter (node: (node.type == "dir")) nodes));
  in {
    home.persistence.${cfg.cowPath} = {
      allowOther = false;
      directories = nodes2dirPersistence cfg.cowNodes;
      files = nodes2filePersistence cfg.cowNodes;
    };

    home.persistence.${cfg.nocowPath} = {
      allowOther = false;
      directories = nodes2dirPersistence cfg.nocowNodes;
      files = nodes2filePersistence cfg.nocowNodes;
    };

    # NOTE: tmpfiles does not create subvolume for unknown reason <NixOS 23.11>
    systemd.user.tmpfiles.rules = let
      generateSingleTmpfileLine = savePath: node: (let
        outPath =
          builtins.toString (lib.path.append (/. + savePath)
            (lib.path.removePrefix (/. + homeDirectory) (/. + node.path)));
        # outPath = "${savePath}/${(getRelPathFromHome node.path)}";

        tmpfileType =
          if (node.type == "dir")
          then "d"
          else (throw "${node.path} is not directory");
      in ''${tmpfileType} "${outPath}" ${node.mode} ${username} users'');

      generateTmpfileLines = savePath: nodes: (map (node: (generateSingleTmpfileLine savePath node))
        (builtins.filter (node: node.type == "dir") nodes));
    in (lib.concatLists [
      [
        ''v "${cfg.cowPath}" 700 ${username} users''
        ''v "${cfg.nocowPath}" 700 ${username} users''
        ''H "${cfg.nocowPath}" - - - - +C'' # -- nocow
        ''R "${cfg.cowPath}/.Trash-*"''
        ''R "${cfg.nocowPath}/.Trash-*"''
      ]
      (generateTmpfileLines cfg.cowPath cfg.cowNodes)
      (generateTmpfileLines cfg.nocowPath cfg.nocowNodes)
    ]);
  });
}
