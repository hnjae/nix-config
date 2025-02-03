{
  config,
  pkgs,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  # run ssh -T git@github.com to test
  sshFamousHosts = pkgs.writeText "ssh-famous-hosts" ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';
in
{
  config = lib.mkIf baseHomeCfg.isHome {
    programs.ssh = {
      enable = true;
      userKnownHostsFile = builtins.concatStringsSep " " [
        "~/.ssh/known_hosts"
        sshFamousHosts
      ];
    };
  };
}
