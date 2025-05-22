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

  end_path = "/sys/class/power_supply/BAT0/charge_control_end_threshold";
  start_path = "/sys/class/power_supply/BAT0/charge_control_start_threshold";

  pkgsRestore = pkgs.writeTextFile {
    name = "restore-battery-threshold";
    executable = true;
    text = ''
      #!${pkgs.dash}/bin/dash
      set -eu

      echo 96 >"${end_path}"
      echo 91 >"${start_path}"
    '';
  };

  pkgsLimit = pkgs.writeTextFile {
    name = "limit-battery-threshold";
    executable = true;
    # NOTE: should edit start-path first then end-path
    text = ''
      #!${pkgs.dash}/bin/dash
      set -eu

      echo 70 >"${start_path}"
      echo 75 >"${end_path}"
    '';
  };

  # NOTE: final.target 은 작동하지 않음. <2024-01-27>
  restoreServices = listToAttrs (
    map (
      unit:
      let
        stem = builtins.replaceStrings [ ".target" ] [ "" ] unit;
      in
      {
        name = "restore-battery-threshold-${stem}";
        value = {
          description = "restore battery threshold";
          before = [ unit ];
          wantedBy = [ unit ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgsRestore}";
          };
        };
      }
    ) [ "sleep.target" ]
  );

  # NOTE: After=suspend.target 이면 resume 후 잘 켜짐 <NixOS 23.11>
  # TODO: hibernate.target 같은거 필요할까? suspend.target 으로 잘 작동하지
  # 않을까 싶음데.. <2024-01-24>
  # => `suspend.target` 만으로 hibernate 시에도 잘 작동 된다.
  limitServices = listToAttrs (
    map
      (
        unit:
        let
          stem = builtins.replaceStrings [ ".target" ] [ "" ] unit;
        in
        {
          name = "limit-battery-threshold-${stem}";
          value = {
            description = "limit battery threshold";
            after = [ unit ];
            wantedBy = [ unit ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgsLimit}";
            };
          };
        }
      )
      # "hibernate.target"
      # "hybrid-sleep.target"
      # "suspend-then-hibernate.target"
      [ "suspend.target" ]
  );

  multiUserService = {
    "control-battery-threshold" = {
      description = "limit/restore battery threshold";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgsLimit}";
        ExecStop = "${pkgsRestore}";
      };
    };
  };
in
{
  systemd.services = lib.attrsets.mergeAttrsList [
    limitServices
    restoreServices
    multiUserService
  ];
}
