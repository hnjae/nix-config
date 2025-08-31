{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";
  isPodman = config.virtualisation.oci-containers.backend == "podman";
in
{
  virtualisation.oci-containers.backend = lib.mkOverride 999 "podman";

  virtualisation.docker = {
    enable = lib.mkOverride 999 (!isPodman);
  };

  virtualisation.podman = {
    enable = lib.mkOverride 999 isPodman;
    dockerSocket.enable = lib.mkOverride 999 true;
    dockerCompat = lib.mkOverride 999 isDesktop;
    # https://github.com/containers/common/blob/main/docs/containers.conf.5.md
    defaultNetwork.settings = lib.mkOverride 999 {
      dns_enabled = true;
      ipv6_enabled = false;
    };
  };

  environment.systemPackages = lib.flatten [
    (lib.lists.optionals isPodman (
      with pkgs;
      [
        podlet
        podman-compose
        podman-tui
      ]
    ))
    (lib.lists.optional ((!isPodman) || config.virtualisation.podman.dockerCompat) pkgs.docker-compose)
  ];

  virtualisation.containers.storage.settings.storage = lib.mkIf isPodman {
    graphroot = "/var/lib/containers/storage";
    runroot = "/run/containers/storage";
  };
}
