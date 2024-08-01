{
  config,
  lib,
  ...
}: let
  inherit (config.home) homeDirectory username;
  inherit (builtins) concatLists;
  utils = (import ./utils.nix) {inherit username;};
  inherit (utils) createTmpfiles createPersistDirs createPersistFiles;

  # kdePath = "${homeDirectory}/.persist-kde/@cow";
  # kdeNocowPath = "${homeDirectory}/.persist-kde/@nocow";

  kdeDirs = (import ./mode2dirs/kde.nix).dirs;
  kdeFiles = (import ./mode2dirs/kde.nix).files;

  kdeNocowDirs = (import ./mode2dirs/kde-nocow.nix).dirs;
  kdeNocowFiles = (import ./mode2dirs/kde-nocow.nix).files;

  cfg = config.plasma6.persistence;
in {
  options.plasma6.persistence = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    path = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        "cow" = "${homeDirectory}/.persist-kde/@cow";
        "nocow" = "${homeDirectory}/.persist-kde/@nocow";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # NOTE: tmpfiles does not create subvolume for unknown reason <NixOS 23.11>
    systemd.user.tmpfiles.rules = concatLists [
      [
        "v ${cfg.path.cow} 700 ${username} users"
        "v ${cfg.path.nocow} 700 ${username} users"
        "H ${cfg.path.nocow} - - - - +C"
      ]
      (createTmpfiles true cfg.path.cow kdeDirs)
      # (createTmpfiles false cfg.path.cow kdeFiles)
      (createTmpfiles true cfg.path.nocow kdeNocowDirs)
      # (createTmpfiles false cfg.path.nocow kdeNocowFiles)
    ];

    # NOTE: persistence 모듈을 쓰면, 아래에서 해당 내용을 지우면 자동으로 symlink
    # 를 삭제해줌. <2024-01-28>
    home.persistence."${cfg.path.nocow}" = {
      allowOther = false;
      directories = concatLists [(createPersistDirs kdeNocowDirs)];
      files = concatLists [(createPersistFiles kdeNocowFiles)];
    };
    home.persistence."${cfg.path.cow}" = {
      allowOther = false;
      directories = concatLists [(createPersistDirs kdeDirs)];
      files = concatLists [(createPersistFiles kdeFiles)];
    };
  };
}
