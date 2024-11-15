{config, ...}: let
  ScriptsName = "snapraid-snapper";
  Unit = {
    Description = "run daily snapraid";
    Documentation = ["man:snapraid(1)"];
  };
in {
  xdg.dataFile.".local/bin/${ScriptsName}" = {
    source = ./sources/snapraid-snapper;
    executable = true;
  };

  systemd.user.services."${ScriptsName}" = {
    inherit Unit;

    Service = {
      Type = "oneshot";
      # ExecStart = "${config.xdg.dataHome}/scripts/snapraid-snapper";
      ExecStart = "${config.xdg.home}/.local/bin/${ScriptsName}";
    };
  };

  systemd.user.timers."snapraid-snapper" = {
    inherit Unit;

    Timer = {
      # OnActiveSec="1d";
      # OnUnitActiveSec = "1d";
      # OnBootSec = "1m";
      # AccuracySec = "15m";
      #  *-*-02,04,06,08,10,12,14,16,18,20,22,24,26,28,30 00:00:00
      OnCalendar = "Mon,Wed,Fri *-*-* 02:00:00";
      RandomizedDelaySec = "60";
      Persistent = true;
    };

    Install = {WantedBy = ["timers.target"];};
  };
}
