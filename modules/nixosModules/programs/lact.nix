# https://github.com/ilya-zlobintsev/LACT
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.lact;
in
{
  options.programs.lact = {
    enable = lib.mkEnableOption '''';
    package = lib.mkPackageOption pkgs "lact" { };
    ppfeaturemask = lib.mkOption {
      type = lib.types.str;
      default = "0xfffd7fff";
      example = "0xffffffff";
      description = ''
        run
        ```sh
        printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))"
        ```
        from [ArchWiki](https://wiki.archlinux.org/title/AMDGPU#Boot_parameter)
      '';
    };

    # WIP:  <2024-08-12>
    gui = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.defaultPackages = [ cfg.package ];
    boot.kernelParams = [ "amdgpu.ppfeaturemask=${cfg.ppfeaturemask}" ];

    /*
      [Unit]
      Description=AMDGPU Control Daemon
      After=multi-user.target

      [Service]
      ExecStart=/nix/store/mnxlbcb3ciys8d7ag38h29ifg50y2ln4-lact-0.5.4/bin/lact daemon
      Nice=-10

      [Install]
      WantedBy=multi-user.target
    */

    # uses package's systemd unit
    systemd.services.lactd = {
      enable = true;

      # Unit
      description = "AMDGPU Control Daemon";
      after = [ "multi-user.target" ];

      # Service
      serviceConfig = {
        Nice = -10;
        ExecStart = "${cfg.package}/bin/lact daemon";
      };

      # Install
      wantedBy = [ "multi-user.target" ];
    };
  };
}
