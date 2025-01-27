{
  lib,
  pkgs,
  ...
}:
let
  aliases = {
    sc = "systemctl";
    scu = "systemctl --user";

    sclst = "systemctl list-timers";
    sculst = "systemctl --user list-timers";

    sc-failed = "systemctl --failed";
    sc-ufailed = "systemctl --user --failed";

    scx = "sudo systemctl start";
    scux = "systemctl --user start";

    scst = "systemctl status";
    scust = "systemctl --user status";

    scrx = "sudo systemctl restart";
    scurx = "systemctl --user restart";

    jc = "journalctl";
    jcu = "journalctl --user";

    jcx = "journalctl -xeu";
    jcux = "journalctl --user -xeu";
  };
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') aliases)
    );
  };
}
