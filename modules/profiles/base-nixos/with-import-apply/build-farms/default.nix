{ localFlake, flake-parts-lib, ... }:
{ config, lib, ... }:
let
  inherit (flake-parts-lib) importApply;
in
{
  imports = [
    (importApply ./horus.nix { inherit localFlake; })
  ];

  #############################################################################
  # SSH Serve
  #############################################################################
  # A list of names of users that have additional rights when connecting to the Nix daemon, such as the ability to specify additional binary caches, or to import unsigned NARs.
  nix.settings.trusted-users = lib.lists.optional config.nix.sshServe.enable "nix-ssh";

  nix.sshServe = {
    enable = true;
    write = true;
    protocol = "ssh-ng";
    keys = [
      localFlake.shared.keys.ssh.nix-ssh
    ];
  };

  #############################################################################
  # Distributed Builds
  #############################################################################
  nix.distributedBuilds = true;

  # when the builder has a faster internet connection then yours
  nix.settings.builders-use-substitutes = true;

  # `nix.buildMachines` 에 사용할 `sshKey` 값을 지정할 수 있지만 /root/.ssh/id_ed25519 에 해당키가 있어야 함.
  # 버그인감. <NixOS 24.11>
  sops.secrets.nix-ssh-prv-key = {
    format = "binary";
    mode = "0400";
    owner = "root";
    group = "root";
    path = "/root/.ssh/id_ed25519";
    sopsFile = ./secrets/nix-ssh.id_ed25519;
  };

  # <https://docs.github.com/en/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints>
  programs.ssh.knownHosts = {
    "github.com" = {
      publicKey = ''SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU'';
      hostNames = [ "github.com" ];
    };
  };
}
