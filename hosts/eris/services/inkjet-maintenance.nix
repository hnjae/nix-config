let
  serviceName = "inkjet-maintenance";
  printer = "athena";
in
{
  pkgs,
  lib,
  ...
}:
{
  services.printing = {
    enable = true;
    stateless = true;
    webInterface = false;
    tempDir = "/tmp/cups"; # default: /tmp
    listenAddresses = [ ];
    browsed.enable = false;
  };

  hardware.printers.ensurePrinters = [
    {

      name = printer;
      deviceUri = "ipp://192.168.0.100/ipp/print";
      model = "everywhere";
    }
  ];

  # systemd =
  #   let
  #     documentation = [ "man:lp(1)" ];
  #     description = "Print test page to maintain inkjet printer nozzles";
  #   in
  #   {
  #     timers."${serviceName}" = {
  #       inherit documentation description;
  #
  #       wantedBy = [ "timers.target" ];
  #       timerConfig = {
  #         RandomizedDelaySec = "30m";
  #         OnCalendar = [
  #           "*-*-5,11,16,22,28 04:00:00"
  #         ];
  #         Persistent = true;
  #       };
  #     };
  #
  #     services."${serviceName}" = {
  #       inherit documentation description;
  #
  #       unitConfig = rec {
  #         After = Wants ++ Requires;
  #         Wants = [ "network-online.target" ];
  #         Requires = [ "cups.service" ];
  #       };
  #
  #       serviceConfig = {
  #         Type = "oneshot";
  #         PrivateTmp = true;
  #
  #         # 커널 스케쥴링
  #         Nice = 19;
  #
  #         ExecStart = lib.escapeShellArgs [
  #           "${pkgs.cups}/bin/lp"
  #           "-d"
  #           printer
  #           "-o"
  #           "media=A4"
  #           "-o"
  #           "print-quality=3" # draft
  #           "-q"
  #           "1"
  #           "pdf"
  #         ];
  #       };
  #     };
  #   };
}
