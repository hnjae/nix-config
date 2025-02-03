{ ... }:
{
  # NOTE: 어떤 애플리케이션 (e.g. fd) 는 LS_COLORS 가 있어야만이 정상 색상을 입힘. (fd 의 경우 LS_COLORS 가 없다면 터미널의 ANSI 색상을 활용 못함) <2024-11-25>
  programs.dircolors = {
    enable = true;
    settings = {
      # extra image formats
      ".heic" = "01;35";
      ".jp2" = "01;35";
      ".jxl" = "01;35";
    };
  };
}
