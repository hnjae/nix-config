{
  pkgsUnstable,
  lib,
  ...
}: {
  home.packages = [pkgsUnstable.zsh-abbr];

  # 또는 https://github.com/simnalamburt/zsh-expand-all 이거 써보자.

  /*
  NOTE:

  사용하기 전에
  `abbr import-aliases` 를 실행해서 `$XDG_CONFG_HOME/zsh-abbr/user-abbrevations` 에 필요한 파일을 생성하는 작업이 필요.

  */
  # TODO: home.shellAliases 를 바탕으로 $XDG_CONFG_HOME/zsh-abbr/user-abbrevations 파일 생성 <2024-12-26>

  programs.zsh = {
    sessionVariables = {
      ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY = 1;
    };
    initExtra = lib.mkBefore ''
      . "${pkgsUnstable.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh"
    '';
  };
}
