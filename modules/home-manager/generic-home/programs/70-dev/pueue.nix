{pkgsUnstable, ...}: let
  package = pkgsUnstable.pueue;
in {
  # https://github.com/Nukesor/pueue
  home.packages = [package];
  home.shellAliases = {
    p = "pueue";
  };
  systemd.user.services.pueued = {
    Unit = {
      Description = "pueue daemon";
      Documentation = ["pueue --help"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${package}/bin/pueued";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
