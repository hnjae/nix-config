{
  config,
  pkgs,
  lib,
  ...
}:
{
  config.fonts = lib.mkIf (config.base-nixos.role == "desktop") {
    fontDir.enable = lib.mkOverride 999 true;
    packages = builtins.concatLists [
      (lib.lists.optionals pkgs.config.allowUnfree (
        with pkgs;
        [
          fonts-kopub-world
        ]
      ))
      (with pkgs; [
        pretendard
        pretendard-jp
        fonts-freesentation

        # noto-fonts
        noto-fonts-extra
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # emoji
        noto-fonts-color-emoji
        # openmoji-color

        # NedFonts
        # https://github.com/NixOS/nixpkgs/blob/8764d898c4f365d98ef77af140b32c6396eb4e02/pkgs/data/fonts/nerdfonts/shas.nix
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
        (nerdfonts.override {
          fonts = [
            "Meslo"
            "IBMPlexMono"
            "D2Coding"
            "0xProto"
            # "NerdFontsSymbolsOnly"
          ];
        })

        # chinese character
        jigmo # 일본 자형 Sans-Serif (hanazono successor)
        fonts-plangothic # ofl

        # others
        fonts-ridibatang # ofl
        d2coding

        # https://wiki.archlinux.org/title/Metric-compatible_fonts
        liberation_ttf # replace: Times New Roman, Arial, and Courier New
        liberation-sans-narrow # replace: Arial Narrow
        # fonts-dmca-sans-serif # replace: consolas
        # carlito # replace: calibri
        # caladea # replace: campria

        #
        wqy_microhei # replace: Microsoft YaHei, SimHei, SimSun
        ipafont # replace: MS [P]{Mincho, Gothic}
      ])
    ];
  };
}
