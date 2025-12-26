let
  serviceName = "inkjet-maintenance";
  printer = "athena";
  ippUrl = "ipp://192.168.0.100/ipp/print";
in
{
  pkgs,
  config,
  lib,
  ...
}:
let
  maintenancePdf = pkgs.requireFile {
    name = "Toner_Print_Quality_Sheets_Colour.pdf";
    url = "https://www.cartridgepeople.com/info/download_file/force/1936/800"; # 실제로는 사용자에게 안내용
    sha256 = "deb3140829770939c51f582df7e88e0d0ac33651206b2b3e2ed665d2b4b34b4b";
    message = ''
      Get PDF from following link: <https://www.cartridgepeople.com/info/download_file/force/1936/800>

      add with

      ```sh
      nix-store --add-fixed sha256 Toner_Print_Quality_Sheets_Colour.pdf
      ```
    '';
  };
in

{
  assertions = [
    {
      assertion = config.services.printing.enable;
      message = "${serviceName} requires printing service to be enabled";
    }
    {
      assertion = lib.any (p: p.name == printer) config.hardware.printers.ensurePrinters;
      message = "${serviceName} requires ${printer} printer to be configured";
    }
  ];

  services.printing = {
    enable = true;
    stateless = true;
    webInterface = false;
    listenAddresses = [ ];
    browsed.enable = false;
    /*
      NOTE: NixOS 25.11
      - tempDir 을 /tmp/cups 로 지정하면, universal filter failed. 오류가 발생.
      - /tmp/cups 디렉토리가 존재하지 않아 발생하는 문제인가? 더 디깅은 굳이 하지 않음.
      - PrivateTmp = true; 문제인가 싶기도 하나, cli 로 직접 실행해도 동일 오류 발생.
    */
    # tempDir = "/tmp"; # DO NOT TOUCH THIS
  };

  hardware.printers.ensurePrinters = [
    {
      name = printer;
      deviceUri = ippUrl;
      model = "everywhere";
    }
  ];

  systemd =
    let
      documentation = [ "man:lp(1)" ];
      description = "Print test page to maintain inkjet printer nozzles";
    in
    {
      timers."${serviceName}" = {
        inherit documentation description;

        wantedBy = [ "timers.target" ];
        timerConfig = {
          RandomizedDelaySec = "30m";
          OnCalendar = [
            # "*-*-5,11,16,22,28 04:00:00"
            "Sun *-*-* 04:00:00"
          ];
          Persistent = true;
        };
      };

      services."${serviceName}" = {
        inherit documentation description;

        unitConfig = rec {
          After = Wants ++ Requires;
          Wants = [
            "network-online.target"
          ];
          Requires = [
            "cups.service"
            "ensure-printers.service"
          ];
        };

        serviceConfig = {
          Type = "oneshot";

          # 커널 스케쥴링
          Nice = 19;

          ExecStart = lib.escapeShellArgs [
            "${pkgs.cups}/bin/lp"
            "-d"
            printer
            "-o"
            "media=A4"
            "-o"
            # NOTE: 1로 한다고 draft 보다 더 저 퀄리티로 나오는 것은 아님. <2025-12-26>
            "print-quality=3" # 3: draft, 4: normal, 5: high
            "-q" # priority to low
            "1"
            maintenancePdf
          ];

          User = "cups";
          Group = "lp";

          # Security hardening
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateIPC = true;
          PrivateMounts = true;
          PrivateNetwork = true; # 네트워크가 아닌 CUPS 와 통신.
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadWritePaths = [ "/var/run/cups/cups.sock" ]; # CUPS socket 위치.
          RemoveIPC = true;
          RestrictAddressFamilies = [ "AF_UNIX" ]; # Unix Socket 으로 CUPS 와 통신
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native"; # 불필요한 아키텍처 syscall 차단
          SystemCallFilter = "@system-service";
          # NOTE: run `systemd-analyze syscall-filter @system-service` for more details. <2025-12-26>
        };
      };
    };
}
