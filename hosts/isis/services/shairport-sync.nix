# https://github.com/mikebrady/shairport-sync/blob/master/docker/README.md
# TODO: use nixpkgs's version <2025-01-12>
{
  config,
  pkgs,
  ...
}:
let
  serviceName = "shairport";
in
{
  # virtualisation.oci-containers.containers."${serviceName}" = {
  #   image = "docker.io/mikebrady/shairport-sync:latest";
  #   autoStart = true;
  #   environment = {
  #   };
  #   volumes = [
  #   ];
  #   ports = [
  #   ];
  #   extraOptions = [
  #     "--net"
  #     "host"
  #     "--device"
  #     "/dev/snd"
  #   ];
  # };
  environment.systemPackages = [
    (pkgs.shairport-sync.override {
      enableAirplay2 = true;
      # audio backend
      enableAlsa = false;
      enableSndio = false;
      enablePulse = false;
      enablePipewire = true;
      enableJack = false;
    })
  ];

  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    # user = "hnjae";
    # group = "users";
    arguments = builtins.concatStringsSep " " [
      "-v"
      "-o"
      "pw"
    ];
    package = pkgs.shairport-sync-airplay2;
    # package = pkgs.shairport-sync.override {
    #   enableAirplay2 = true;
    #   # audio backend
    #   enableAlsa = false;
    #   enableSndio = false;
    #   enablePulse = false;
    #   enablePipewire = true;
    #   enableJack = false;
    # };
  };
  # networking.firewall = {
  #   allowedUDPPorts = [319 320];
  # };
}
