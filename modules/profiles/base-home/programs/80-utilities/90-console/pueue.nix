{
  pkgs,
  pkgsUnstable,
  lib,
  ...
}:
let
  package = pkgsUnstable.pueue;
in
{
  # https://github.com/Nukesor/pueue
  home.packages = [ package ];

  systemd.user.services.pueued = lib.mkIf (pkgs.stdenv.isLinux) {
    Unit = {
      Description = "pueue daemon";
      Documentation = [ "pueue --help" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${package}/bin/pueued";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
