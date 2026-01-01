{ localFlake, projectName, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.services.${projectName};

  inherit (pkgs.stdenv) hostPlatform;
  package = localFlake.packages.${hostPlatform.system}.${projectName};
in
{
  options.my.services.${projectName} = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
      }
    ];

    environment.systemPackages = [
      package
    ];

    systemd =
      let
        documentation = [
        ];
        description = "";
      in

      {
        services.${projectName} = {
          inherit documentation description;
          after = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
          };
        };

        timers.${projectName} = {
          inherit documentation description;

          wantedBy = [ "timers.target" ];
          timerConfig = {
          };
        };
      };
  };
}
