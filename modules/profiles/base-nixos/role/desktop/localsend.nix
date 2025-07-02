{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (config.base-nixos.role == "desktop") {

    # programs.localsend.enable = true;
    # localsend
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };

    home-manager.sharedModules = [
      {
        # NOTE: system-wide flatpak 말고 user 사용 (라이브러리 공유)
        services.flatpak.packages = [
          # font 깨짐 <NixOS 25.05>
          "org.localsend.localsend_app" # should open 53317
        ];
        services.flatpak.overrides."org.localsend.localsend_app" = {
          Context = {
            filesystems = [
              "home"
              "!xdg-config"
              # "xdg-download"
              # "xdg-public-share"
              # "xdg-pictures"
              # "xdg-desktop"
              # "xdg-documents"
              # "xdg-videos"
              # "xdg-music"
            ];
          };
        };
      }
    ];
  };
}
