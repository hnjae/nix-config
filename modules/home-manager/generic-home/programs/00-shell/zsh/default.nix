{
  config,
  pkgsUnstable,
  ...
}: let
  # inherit (config.home) shellAliases;
  # inherit (lib.strings) optionalString;
  concat = builtins.concatStringsSep "\n";
in {
  imports = [
    # ./zsh-vi-mode.nix
    ./profile.nix
  ];

  home.packages = [
    # provides various /nix/store/<hash>/share/zsh/site-functions
    pkgsUnstable.zsh-completions
  ];

  # NOTE: source order:
  # .zshenv, .zprofile, .zlogin(optional?), .zshrc | .zlogout
  # home.sessionVariables 는 .zshenv의 머리에,
  # home.shellAliases 는 .zshrc 말미에 적힘
  # home-manager:
  # localVariables??
  # envExta
  # profileExtra
  # initExtraFirst initExtraBeforeCompInit initExta
  # logoutExtra

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    # NOTE: envExtra being ignored or override for unknown reason <2023-03-26>
    # .zshenv 말미
    # envExtra = "";

    # .zprofle
    # profileExtra = "";

    # .zshrc 중간 (after zplugin, history)
    initExtra = concat [
      ''

        # history 에서 일치하는 명령 줄 배경색으로 표기
        . "${pkgsUnstable.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

        # alias 에 있는 커맨드와 동일하면 표기
        . "${pkgsUnstable.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"

        # syntax highlighting
        . "${pkgsUnstable.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"

        . "${pkgsUnstable.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"

        # run `zhooks` to display functions and array <https://github.com/agkozak/zhooks>
        . "${pkgsUnstable.zsh-zhooks}/share/zsh/zhooks/zhooks.plugin.zsh"
      ''
      # starship, zoxide, skim, direnv, aliases will follow

      ''
        # EDITOR가 vi 이여도, ^A, ^E 같은 emacs 키는 사용할 수 있게 설정
        # https://github.com/simnalamburt/.dotfiles/blob/997d482/.zshrc
        if (( $+commands[vim] )) || (( $+commands[nvim] )); then
          bindkey '^A' beginning-of-line
          bindkey '^E' end-of-line
        fi
      ''
    ];

    history = {
      path = "${config.xdg.stateHome}/zsh_history";
      ignoreDups = true;
      ignorePatterns = config.programs.bash.historyIgnore;
      ignoreSpace = true;
      extended = true; # save timestamp into the history file
      save = 90000;
      size = 90000;
      share = true;
      # use atuin as history manager
    };
  };
}
