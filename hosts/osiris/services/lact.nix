{ pkgs, ... }:
{
  hardware.amdgpu.overdrive.enable = true;
  # services.lact = { # Use this module in NixOS 25.11
  #   enable = true;
  # };

  environment.systemPackages = [ pkgs.lact ];
  systemd.packages = [ pkgs.lact ];

  systemd.services.lactd = {
    description = "LACT GPU Control Daemon";
    wantedBy = [ "multi-user.target" ];
    # Restart when the config file changes.
    # restartTriggers = lib.mkIf (cfg.settings != { }) [ configFile ];
  };

}
