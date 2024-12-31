{
  pkgsUnstable,
  lib,
  ...
}: {
  # Prevent of modifying `$XDG_CONFG_HOME/zsh-abbr/user-abbrevations` by `abbr` command
  # home.packages = [pkgsUnstable.zsh-abbr];

  # 또는 https://github.com/simnalamburt/zsh-expand-all 이거 써보자.

  /*
  NOTE:
  zsh-abbr은 `$XDG_CONFG_HOME/zsh-abbr/user-abbrevations` 파일을 참조.
  */
  programs.zsh = {
    sessionVariables = {
      ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY = 1;
    };
    initExtra = lib.mkBefore ''
      . "${pkgsUnstable.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh"
    '';
  };
}
