{
  pkgs,
  config,
  lib,
}: let
  inherit (config.home) sessionVariables shellAliases;
  inherit (lib.strings) optionalString;
  concat = builtins.concatStringsSep "\n";
in {
  # .zshenv 말미
  envExtra = concat [
    ''
      EDITOR="${sessionVariables.EDITOR}"
    ''
    (optionalString pkgs.stdenv.isLinux ''
      # to use other locale in gui and use en_IE in shell.
      # NOTE: sessionVariables were being ignored by KDE's value (NixOS 22.11)
      LC_TIME="${sessionVariables.LC_TIME}"
    '')
  ];

  envExtraFish = concat [
    ''
      set -x EDITOR "${config.home.sessionVariables.EDITOR}"
    ''
    (optionalString pkgs.stdenv.isLinux ''
      set -x LC_TIME "${config.home.sessionVariables.LC_TIME}"
    '')
  ];

  # .zprofle
  profileExtra = ''
    [ -n "$__PROFILE_SOURCED" ] && return
    __PROFILE_SOURCED=1
  '';

  # config.fish (loginShellInit)
  profileExtraFish = ''
    # config.fish
  '';

  # NOTE: fish does not have historyIgnore features <2023-07-24>
  historyIgnore = [
    # cd
    "cd"
    "z"
    "s"
    # files
    "rm"
    "trash"
    "trash-put"
    "trash-rm"
    "trash-empty"
    "trash-restore"
    "trash-list"
    "mv"
    # ls & misc
    "ls"
    "ll"
    "pwd"
    #
    "clear"
    "exit"
    "fg"
    "bg"
    # dangerous commands
    "reboot"
    "shutdown"
    "halt"
    "kexec"
  ];
}
