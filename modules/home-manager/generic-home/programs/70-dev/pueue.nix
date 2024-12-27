{pkgsUnstable, ...}: let
  package = pkgsUnstable.pueue;
in {
  # https://github.com/Nukesor/pueue
  home.packages = [package];

  home.shellAliases = {
    p = "pueue";
    prm = "pueue remove";
    psw = "pueue switch";
    psh = "pueue stash";
    peq = "pueue enqueue";
    px = "pueue start";
    prx = "pueue restart";
    pps = "pueue pause";
    pK = "pueue kill";
    psd = "pueue send";
    ped = "pueue edit";
    pgr = "pueue group";
    pst = "pueue status";
    pl = "pueue log";
    pfo = "pueue follow";
    pw = "pueue wait";
    pcl = "pueue clean";
    pa = "pueue add";
    ph = "pueue help";
  };

  # programs.zsh.initExtra = ''
  #   abbr -S p="pueue"
  #   abbr -S pst="pueue status"
  # '';

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
