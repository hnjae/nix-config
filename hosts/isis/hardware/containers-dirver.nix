{...}: let
  stDriver = "zfs";
in {
  virtualisation.docker = {
    storageDriver = stDriver;
  };
  virtualisation.containers.storage.settings.storage = {
    driver = stDriver;
  };

  home-manager.sharedModules = [
    ({config, ...}: {
      /*
       NOTE:  <2024-11-28>
      zfs is not supported in rooltless podman
      https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md
      */
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "overlay"
        '';
      };
    })
  ];
}
