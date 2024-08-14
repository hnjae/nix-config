{pkgsUnstable, ...}: {
  programs.zsh = {
    envExtra = ''
      ZVM_CURSOR_STYLE_ENABLED=false
    '';
    initExtra = ''
      # zsh-vi-mode uses C-r
      . "${pkgsUnstable.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
    '';
  };
}
