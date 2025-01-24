# https://github.com/nix-community/impermanence
# Stateful 하게 관리할 파일들.
{
  lib,
  config,
  ...
}:
let
  cfg = config.stateful;

  inherit (lib) mkOption types;
  inherit (builtins) throw;
  inherit (config.home) homeDirectory username;

  nodeType = lib.types.submodule {
    options = {
      path = mkOption { type = types.str; };
      mode = mkOption { type = types.str; };
      type = mkOption {
        type = types.enum [
          "dir"
          "file"
        ];
      };
    };
  };
in
{
  options.stateful = {
    enable = lib.mkEnableOption "";
    path = mkOption {
      type = types.str;
      default = "${homeDirectory}/.persist";
    };
    nodes = mkOption {
      type = types.listOf nodeType;
      default = [ ];
    };
  };

  config = lib.mkIf (cfg.enable) (
    let
      inherit (builtins) substring stringLength;
      getPersistencePath =
        node:
        (
          let
            relPathFromHome = lib.path.removePrefix (/. + homeDirectory) (/. + node.path);
          in
          (
            if ((substring 0 2 relPathFromHome) == "./") then
              (substring 2 ((stringLength relPathFromHome) - 2) relPathFromHome)
            else
              (throw "The following value is not in the format expected: ${relPathFromHome}")
          )
        );

      nodes2filePersistence =
        nodes:
        (map (node: (getPersistencePath node)) (
          builtins.filter (node: (node.type == "file")) nodes
        ));
      nodes2dirPersistence =
        nodes:
        (map (node: {
          directory = getPersistencePath node;
          method = "symlink";
        }) (builtins.filter (node: (node.type == "dir")) nodes));
    in
    {
      home.persistence.${cfg.path} = {
        allowOther = false;
        directories = nodes2dirPersistence cfg.nodes;
        files = nodes2filePersistence cfg.nodes;
      };

      # NOTE: tmpfiles does not create subvolume for unknown reason <NixOS 23.11>
      systemd.user.tmpfiles.rules =
        let
          generateSingleTmpfileLine =
            savePath: node:
            (
              let
                outPath = builtins.toString (
                  lib.path.append (/. + savePath) (
                    lib.path.removePrefix (/. + homeDirectory) (/. + node.path)
                  )
                );

                tmpfileType =
                  if (node.type == "dir") then "d" else (throw "${node.path} is not directory");
              in
              ''${tmpfileType} "${outPath}" ${node.mode} ${username} users''
            );

          generateTmpfileLines =
            savePath: nodes:
            (map (node: (generateSingleTmpfileLine savePath node)) (
              builtins.filter (node: node.type == "dir") nodes
            ));
        in
        (lib.concatLists [
          [
            ''d "${cfg.path}" 700 ${username} users''
            ''R "${cfg.path}/.Trash-*"''
          ]
          (generateTmpfileLines cfg.path cfg.nodes)
        ]);
    }
  );
}
