{pkgs, ...}: {
  programs.plasma.configFile."kwriterc"."General" = {
    "Show welcome view for new window".value = false;
  };
  programs.plasma.configFile."kwriterc"."KTextEditor Document" = {
    "Tab Width".value = 8;
    "Show Tabs".value = true;
  };

  # NOTE: <flatpak kwrite 24.02.2, NixOS 23.11, fcitx5>
  # 한글 입력 이슈:
  # 한글 입력시 커서 전방의 space 가 지워짐. Nix 패키지에서는 동일 현상 無
  # "org.kde.kwrite"

  home.packages = builtins.concatLists [(with pkgs.libsForQt5; [kate])];
}
