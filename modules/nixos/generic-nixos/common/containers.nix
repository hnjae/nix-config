{
  config,
  pkgs,
  lib,
  ...
}: let
  isDesktop = config.generic-nixos.role == "desktop";

  isDocker = config.virtualisation.oci-containers.backend == "docker";
  isPodman = config.virtualisation.oci-containers.backend == "podman";

  storageDriver =
    if config.fileSystems."/".fsType == "btrfs"
    then "btrfs"
    else
      (
        if config.fileSystems."/".fsType == "zfs"
        then "zfs"
        else "overlay2"
      );
in {
  virtualisation.oci-containers.backend = lib.mkOverride 999 "podman";

  virtualisation.docker = {
    enable = lib.mkOverride 999 isDocker;
    inherit storageDriver;
  };

  virtualisation.podman = {
    enable = lib.mkOverride 999 isPodman;
    dockerSocket.enable = lib.mkOverride 999 isDesktop;
    dockerCompat = lib.mkOverride 999 isDesktop;
    defaultNetwork.settings = lib.mkOverride 999 {
      dns_enabled = false;
    };
  };

  environment.systemPackages = builtins.concatLists [
    (
      lib.lists.optional isPodman pkgs.podman-compose
    )
    (
      lib.lists.optional (isDocker || config.virtualisation.podman.dockerCompat) pkgs.docker-compose
    )
  ];

  virtualisation.containers.storage.settings.storage = lib.mkIf isPodman {
    graphroot = "/var/lib/containers/storage";
    runroot = "/run/containers/storage";
    driver = storageDriver;
  };
}
