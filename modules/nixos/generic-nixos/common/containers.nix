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
    else "overlay2";
in {
  virtualisation.oci-containers.backend = lib.mkOverride 999 (
    if isDesktop
    then "docker"
    else "podman"
  );

  virtualisation.docker = {
    enable = lib.mkOverride 999 isDocker;
    inherit storageDriver;
  };

  virtualisation.podman = {
    enable = lib.mkOverride 999 isPodman;
    dockerSocket.enable = lib.mkOverride 999 false;
    dockerCompat = lib.mkOverride 999 false;
    defaultNetwork.settings = lib.mkOverride 999 {
      dns_enabled = false;
    };
  };

  environment.systemPackages = [
    (
      if isPodman
      then pkgs.podman-compose
      else pkgs.docker-compose
    )
  ];

  virtualisation.containers.storage.settings.storage = {
    graphroot = "/var/lib/containers/storage";
    runroot = "/run/containers/storage";
    driver = storageDriver;
  };
}
