{
  pkgs,
  lib,
  ...
}: {
  fonts = {
    fontDir.enable = lib.mkOverride 999 true;
    packages = builtins.concatLists [
      (lib.lists.optionals pkgs.config.allowUnfree (with pkgs; [
        fonts-toss-face
        fonts-kopub-world
        fonts-hanazono-appending
      ]))
      (with pkgs; [
        pretendard
        pretendard-jp

        # noto-fonts
        noto-fonts-extra
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # emoji
        noto-fonts-color-emoji
        # openmoji-color

        # NedFonts
        (nerdfonts.override {
          fonts = [
            "Meslo"
            "IBMPlexMono"
            # "NerdFontsSymbolsOnly"
          ];
        })

        # chinese character
        hanazono # 일본 자형 Sans-Serif
        fonts-plangothic # ofl

        # others
        fonts-ridibatang # ofl
        d2coding

        # https://wiki.archlinux.org/title/Metric-compatible_fonts
        liberation_ttf # replace: Times New Roman, Arial, and Courier New
        liberation-sans-narrow # replace: Arial Narrow
        fonts-dmca-sans-serif # replace: consolas
        # carlito # replace: calibri
        # caladea # replace: campria

        #
        wqy_microhei # replace: Microsoft YaHei, SimHei, SimSun
        ipafont # replace: MS [P]{Mincho, Gothic}
      ])
    ];
  };
}
