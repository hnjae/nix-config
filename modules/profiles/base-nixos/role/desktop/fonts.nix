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

        # NerdFonts
        # https://github.com/NixOS/nixpkgs/blob/8764d898c4f365d98ef77af140b32c6396eb4e02/pkgs/data/fonts/nerdfonts/shas.nix
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
        (nerdfonts.override {
          fonts = [
            # "NerdFontsSymbolsOnly"

            # abcd
            # 가나

            # NOTE: 선정 가이드 <2025-04-19 updated>
            # 1. Slashed zero
            # 2. NO ligatures
            # 3. `f` 기호를 function 기호 (e.g. `󰊕`) 처럼 렌더링 하지 않음
            # 4. 한글 한자가 로마자 두자랑 길이가 비슷
            # <https://www.programmingfonts.org/> 에서 렌더링 결과물을 확인할 수 있다.

            # Slashed Zero & NO ligatures
            "Meslo" # <https://github.com/andreberg/Meslo-Font>
            "RobotoMono"
            "InconsolataLGC"
            "CommitMono" # <https://github.com/eigilnikolajsen/commit-mono> / <https://commitmono.com>
            "CodeNewRoman"

            # 아직 지원 안됨
            # Atkinson Hyperlegible Mono

            # 못 쓰겠을 폰트
            # "Mononoki" # `f` 를 function 기호 처럼 렌더링
            # "Recursive" # `f` 를 function 기호 처럼 렌더링

            # Dotted Zero & NO ligatures
            # "Agave"
            # "FiraMono"
            # "IBMPlexMono"

            # Slashed zero & ligatures
            # "0xProto"
            # "D2Coding"
            # "fira-code"
            # "geist-mono"
            # "jetbrains-mono"
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
