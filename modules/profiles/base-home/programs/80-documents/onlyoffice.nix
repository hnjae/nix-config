{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  appId = "org.onlyoffice.desktopeditors";
in
{
  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      appId
    ];

    services.flatpak.overrides."${appId}" = {
      Context = {
        # INFO: 기본으로 host 파일을 전부 읽을 수 있게 설정되어 있음. <2025-03-21>
        filesystems = [
          "home"
          "!host"
        ];
      };
    };

    default-app.mime = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = appId;
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = appId;

      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = appId;
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = appId;

      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = appId;
      "application/vnd.openxmlformats-officedocument.presentationml.template" = appId;
      # "application/vnd.openxmlformats-officedocument.presentationml.slide" = appId;
      # "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = appId;
    };
  };
}
