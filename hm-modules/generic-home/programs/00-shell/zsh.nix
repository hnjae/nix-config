{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  # inherit (config.home) shellAliases;
  # inherit (lib.strings) optionalString;
  common = (import ./share/common.nix) {inherit pkgs config lib;};
  concat = builtins.concatStringsSep "\n";
in {
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

    # NOTE: envExtra being ignored or override for unknown reason <2023-03-26>
    # .zshenv 말미
    envExtra = concat [
      common.envExtra
      ''
        ZVM_CURSOR_STYLE_ENABLED=false
      ''
    ];

    # .zprofile
    inherit (common) profileExtra;

    # .zshrc 중간 (after zplugin, history)
    initExtra = concat [
      ''
        # plugins
        # zsh-vi-mode uses C-r
        # . "${pkgsUnstable.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

        # history 에서 일치하는 명령 줄 배경색으로 표기
        . "${pkgsUnstable.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        # alias 에 있는 커맨드와 동일하면 표기
        . "${pkgsUnstable.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh"
        . "${pkgsUnstable.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"
        . "${pkgsUnstable.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      ''
      # starship, zoxide, skim, direnv, aliases will follow
    ];

    history = {
      path = "${config.xdg.stateHome}/zsh_history";
      ignoreDups = true;
      ignorePatterns = common.historyIgnore;
      ignoreSpace = true;
      extended = true; # save timestamp into the history file
      save = 90000;
      size = 90000;
      share = true;
      # use atuin as history manager
    };
    dotDir = ".config/zsh";
  };
}
