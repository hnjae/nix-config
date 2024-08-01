{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.generic-nixos) isDesktop;
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
    enable = !config.boot.isContainer && isDocker;
    inherit storageDriver;
  };

  virtualisation.podman = {
    enable = !config.boot.isContainer && isPodman;
    dockerSocket.enable = false;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = false;
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
