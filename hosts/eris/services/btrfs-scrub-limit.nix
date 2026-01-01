/*
  NOTE:
  NixOS 25.11, 6.18
  - `btrfs scrub start` 할때 건내는 `--limit` 플래그는 모든 디바이스가 아니라 한 디바이스에만 limit 이 걸림.
*/
let
  serviceName = "btrfs-scrub-limit";
  target = "/nix";
in
{
  pkgs,
  lib,
  ...
}:
{
  systemd.services.${serviceName} = {
    description = "Limit btrfs scrub speed on /nix";
    documentation = [ "man:btrfs-scrub(8)" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.escapeShellArgs [
        "${pkgs.btrfs-progs}/bin/btrfs"
        "scrub"
        "limit"
        "--all"
        "--limit"
        "256M" # NOTE: 이진접두어 단위
        "--"
        target
      ];
      RemainAfterExit = true;

      # Allowed
      NoNewPrivileges = true;
      PrivateNetwork = true; # No network needed
      ProtectClock = true;
      ProtectKernelModules = true;
    };
  };
}
