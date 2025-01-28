{ ... }:
let
  stDriver = "btrfs";
in
{
  virtualisation.docker = {
    storageDriver = stDriver;
  };
  virtualisation.containers.storage.settings.storage = {
    driver = stDriver;
  };

  home-manager.sharedModules = [
    {
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "${stDriver}"
        '';
      };
    }
  ];
}
