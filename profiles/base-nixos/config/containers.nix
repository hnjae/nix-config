{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDesktop = config.base-nixos.role == "desktop";
  isPodman = config.virtualisation.podman.enable;
in
{
  virtualisation = {
    podman = {
      enable = lib.mkOverride 999 true;
      dockerSocket.enable = lib.mkOverride 999 true;
      dockerCompat = lib.mkOverride 999 isDesktop;

      # https://github.com/containers/common/blob/main/docs/containers.conf.5.md
      defaultNetwork.settings = lib.mkOverride 999 {
        ipv6_enabled = false;
        # default_subnet = "10.88.0.0/16";
      };
      autoPrune = {
        enable = lib.mkOverride 999 true;
        dates = lib.mkOverride 999 "Monday *-*-* 04:00:00";
        flags = lib.mkOverride 999 [ "--all" ];
      };
    };
    oci-containers.backend = lib.mkOverride 999 "podman";
    docker.enable = lib.mkOverride 999 false;
  };

  environment.systemPackages = lib.flatten [
    (lib.lists.optional isPodman (
      with pkgs;
      [
        podlet
        podman-compose
        podman-tui
      ]
    ))
    (lib.lists.optional (isPodman && config.virtualisation.podman.dockerCompat) pkgs.docker-compose)
  ];

  virtualisation.containers.storage.settings.storage = {
    graphroot = "/var/lib/containers/storage";
    runroot = "/run/containers/storage";
  };
}
