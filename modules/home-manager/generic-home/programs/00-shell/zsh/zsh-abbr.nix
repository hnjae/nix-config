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
  # TODO: abbr import-aliases 를 system activation 할때 실행 할 수 있을까?  <2024-12-24>

  programs.zsh = {
    initExtra = lib.mkAfter ''
      . "${pkgsUnstable.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh"
    '';
  };
}
