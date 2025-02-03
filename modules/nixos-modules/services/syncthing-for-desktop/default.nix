{ pkgs, ... }:
let
  username = "hnjae";
in
{
  config = {
    # NOTE: 사용하는 포트
    # 8384: Web UI
    # 22000/tpc,udp: file transfers
    # 21027/udp # local discovery broadcasts
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [
        21027
        22000
      ];
    };

    home-manager.users.${username} = _: {
      imports = [
        ./hmModule.nix
      ];
    };

    systemd.services.syncthing = {
      description = "Syncthing service";
      after = [ "network.target" ];
      environment = {
        STNORESTART = "yes";
        STNOUPGRADE = "yes";
      };
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        Restart = "on-failure";
        SuccessExitStatus = "3 4";
        RestartForceExitStatus = "3 4";
        User = username;
        Group = "users";
        ExecStart = ''
          ${pkgs.syncthing}/bin/syncthing -no-browser
        '';
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        CapabilityBoundingSet = [
          "~CAP_SYS_PTRACE"
          "~CAP_SYS_ADMIN"
          "~CAP_SETGID"
          "~CAP_SETUID"
          "~CAP_SETPCAP"
          "~CAP_SYS_TIME"
          "~CAP_KILL"
        ];
      };
    };
  };
}
