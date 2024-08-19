{
  config,
  lib,
  ...
}: let
  appId = "org.mozilla.Thunderbird";
  genericHomeCfg = config.generic-home;
in {
  config = lib.mkIf genericHomeCfg.isDesktop {
    services.flatpak.packages = [appId];
    services.flatpak.overrides."${appId}" = {
      Context = {sockets = ["!x11"];};
    };

    # NOTE: pref.js 파일 수정은 안된다. Identity 설정 같은 건 불가능 <NixOS 23.11>
    # NOTE: home-manager의 thunderbird 모듈은 사용하지 말자. 프로그램의 처음 부터
    # 끝까지 declare 할 수 있는 류의 프로그램 말고는 별로인 것 같다.
    programs.thunderbird.enable = false;
  };
}
