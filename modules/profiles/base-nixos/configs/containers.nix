{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";

  isDocker = config.virtualisation.oci-containers.backend == "docker";
  isPodman = config.virtualisation.oci-containers.backend == "podman";
in
{
  virtualisation.oci-containers.backend = lib.mkOverride 999 "podman";

  virtualisation.docker = {
    enable = lib.mkOverride 999 isDocker;
  };

  virtualisation.podman = {
    enable = lib.mkOverride 999 isPodman;
    dockerSocket.enable = lib.mkOverride 999 isDesktop;
    dockerCompat = lib.mkOverride 999 isDesktop;
    defaultNetwork.settings = lib.mkOverride 999 {
      dns_enabled = false;
    };
  };

  environment.systemPackages = lib.flatten [
    (lib.lists.optionals isPodman (
      with pkgs;
      [
        podman-compose
        podlet
      ]
    ))
    (lib.lists.optional (isDocker || config.virtualisation.podman.dockerCompat) pkgs.docker-compose)
  ];

  virtualisation.containers.storage.settings.storage = lib.mkIf isPodman {
    graphroot = "/var/lib/containers/storage";
    runroot = "/run/containers/storage";
  };
}
