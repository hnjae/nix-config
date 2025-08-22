/*
  NOTE:
    - To download binary: <https://cidercollective.itch.io/cider>
    - flatpak version of cider-2 does not register icon <2.6.1; 2025-03-21>

    - nixpkgs 의 `cider-2` 는 다음의 이슈가 있음.
      - `cider-2.desktop` 이라는 이름으로 등록, `startupWMClass`은 `cider` 인데, 정작 실행한 인스턴스의
      클래스 이름은 `Cider` 임. `startupWMClass` 는 무시되나? <2.6.1; AppImage; Gnome 47.2>
      - <https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ci/cider-2/package.nix>
      - "Cider" 이라는 이름을 어거지로 `cider-2` 로 재명명하려다가 생긴 이슈 같다.
*/
{
  pkgs,
  pkgsUnstable,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  package = pkgs.appimageTools.wrapType2 rec {
    pname = "Cider";
    inherit (pkgsUnstable.cider-2)
      # version
      # src
      meta
      ;

    version = "3.0.2";

    # NOTE: 2025-05-29 기준 nixos-unstable-small 에서 `cider-2` 의 src 가 잘못 선언되어 있음.
    src = pkgs.requireFile {
      name = "cider-v${version}-linux-x64.AppImage";
      url = "https://taproom.cider.sh/downloads";
      sha256 = "XVBhMgSNJAYTRpx5GGroteeOx0APIzuHCbf+kINT2eU=";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    extraInstallCommands =
      let
        contents = pkgs.appimageTools.extract {
          inherit version src pname;
        };
        icon = "${contents}/usr/share/icons/hicolor/256x256/cider.png";
      in
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ci/cider-2/package.nix
      ''
        wrapProgram $out/bin/${pname} \
           --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
           --add-flags "--no-sandbox --disable-gpu-sandbox"

        install -m 444 -D ${contents}/Cider.desktop $out/share/applications/${pname}.desktop

        substituteInPlace "$out/share/applications/${pname}.desktop" \
          --replace-warn 'Icon=cider' 'Icon=${pname}'

        # 적어도 Gnome 에서는 의미 없는 것 같지만..
        substituteInPlace "$out/share/applications/${pname}.desktop" \
          --replace-warn 'StartupWMClass=cider' 'StartupWMClass=${pname}'

        mkdir -p "$out/share/icons/hicolor/256x256/apps"
        cp --reflink=auto "${icon}" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
      '';

  };
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop && baseHomeCfg.isHome && pkgs.config.allowUnfree) {
    home.packages = [ package ];
  };
}
