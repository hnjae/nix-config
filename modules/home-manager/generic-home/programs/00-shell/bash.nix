{
  config,
  lib,
  ...
}: {
  programs.bash = {
    enable = false;

    # NOTE: profileExtra won't be sourced while using terminal like a konsole
    # ~/.profile
    profileExtra = lib.mkOrder 1 ''
      [ -n "$__PROFILE_SOURCED" ] && return
      __PROFILE_SOURCED=1
    '';

    # head of ~/.bashrc
    bashrcExtra = lib.mkOrder 1 ''
      # ~/.profile 을 source 안하는 경우 대응
      [ -z "$__PROFILE_SOURCED" ] && [ -f "$HOME/.profile" ] &&
        . "$HOME/.profile"

      # 아래 두 라인은 bash -el 로 스크립트를 작성할때 문제가 생김. (home-manager 에서 겪음)
      # 적절하게 설정하는게 아닌 듯 하다.
      # set editing-mode vi
      # set keymap vi-command
      # vi-insert or vi-command
    '';

    # in the middle of ~/.bashrc (after alias)
    initExtra = "";

    # logoutExtra

    # let the terminal track the pwd
    enableCompletion = true;
    enableVteIntegration = false;

    historyFile = "${config.xdg.stateHome}/bash_history";
    # NOTE: fish does not have historyIgnore features <2023-07-24>
    historyIgnore = [
      # cd
      "cd"
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

    historyControl = ["erasedups" "ignoredups" "ignorespace"];
  };
}
