# TODO: Make <https://github.com/GabePoel/KvLibadwaita> as package <2025-01-06>
/*
  NOTE: 현재로서는 다음의 작업이 필요.
    * KvLibadwaita 를 직접 설치.
    * 일부 flatpak 앱 (e.g. dolphin, strawberry) 에서는 kvantum 사용 불가능 kvantum 이 해당 runtime 을 지원 X <NixOS 24.11>
*/
{
  lib,
  ...
}:
{
  # https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
  qt = {
    enable = true;
    style = "kvantum";
    # platformTheme = "qt5ct";
  };

  home-manager.sharedModules = [
    (
      { ... }:
      {
        xdg.configFile."Kvantum/kvantum.kvconfig".text = lib.generators.toINI { } {
          General.theme = "KvLibadwaita";
        };

        # services.flatpak.packages =
        #   let
        #     arch = pkgs.stdenv.hostPlatform.ubootArch;
        #   in
        #   [
        #     # NOTE: 2025-01-06 checked
        #     "org.kde.KStyle.Kvantum/${arch}/5.15"
        #     "org.kde.KStyle.Kvantum/${arch}/5.15-21.08"
        #     "org.kde.KStyle.Kvantum/${arch}/5.15-22.08"
        #     "org.kde.KStyle.Kvantum/${arch}/5.15-23.08"
        #     "org.kde.KStyle.Kvantum/${arch}/6.5"
        #     "org.kde.KStyle.Kvantum/${arch}/6.6"
        #   ];
        #
        # # ~/.local/share/flatpak/overrides
        # services.flatpak.overrides = {
        #   "global" = {
        #     Context = {
        #       filesystems = [ "xdg-config/Kvantum:ro" ];
        #     };
        #     # Environment = {
        #     #   QT_STYLE_OVERRIDE = "kvantum";
        #     # };
        #   };
        # };
      }
    )
  ];
}
