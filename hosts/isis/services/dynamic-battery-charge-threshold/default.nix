# NOTE:
# run `systemctl list-dependencies --all --recursive  <target-name>` to list
# dependencies
# NOTE: exit.target == poweroff.target on non-container system <2023-12-31>
# https://man.archlinux.org/man/systemd.special.7
# https://unix.stackexchange.com/questions/39226/how-to-run-a-script-with-systemd-right-before-shutdown
{
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) listToAttrs;

  package = (import ./package { inherit pkgs; });
  exec = "${package}/bin/set-charge-threshold";
  execLimit = "${exec} -l 90 -r 4";
  execRestore = "${exec} -l 70 -r 15";

  # NOTE: final.target 은 작동하지 않음. <2024-01-27>
  restoreServices = listToAttrs (
    map (
      unit:
      let
        stem = builtins.replaceStrings [ ".target" ] [ "" ] unit;
      in
      {
        name = "restore-battery-charge-threshold-${stem}";
        value = {
          description = "restore battery charge threshold";
          before = [ unit ];
          wantedBy = [ unit ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = execRestore;
          };
        };
      }
    ) [ "sleep.target" ]
  );

  # NOTE: After=suspend.target 이면 resume 후 잘 켜짐 <NixOS 23.11>
  # NOTE: `suspend.target` 만으로 hibernate 시에도 잘 작동 된다. <NixOS 23.11>
  limitServices = listToAttrs (
    map
      (
        unit:
        let
          stem = builtins.replaceStrings [ ".target" ] [ "" ] unit;
        in
        {
          name = "limit-battery-charge-threshold-${stem}";
          value = {
            description = "limit battery charge threshold";
            after = [ unit ];
            wantedBy = [ unit ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = execLimit;
            };
          };
        }
      )
      # "hibernate.target"
      # "hybrid-sleep.target"
      # "suspend-then-hibernate.target"
      [ "suspend.target" ]
  );
in
{
  environment.systemPackages = [ package ];
  systemd.services = lib.attrsets.mergeAttrsList [
    limitServices
    restoreServices
    ({
      "control-battery-charge-threshold" = {
        description = "limit/restore battery charge threshold";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = execLimit;
          ExecStop = execRestore;
        };
      };
    })
  ];
}
