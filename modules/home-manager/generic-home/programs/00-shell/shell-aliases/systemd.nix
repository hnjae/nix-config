{
  lib,
  pkgs,
  ...
}: let
  aliases = {
    sc = "systemctl";
    scu = "systemctl --user";

    scst = "systemctl status";
    scust = "systemctl --user status";

    sclst = "systemctl list-timers";
    sculst = "systemctl --user list-timers";

    sc-failed = "systemctl --failed";
    sc-ufailed = "systemctl --user --failed";

    sc-restart = "systemctl --restart";
    scu-restart = "systemctl --user --restart";

    jc = "journalctl";
    jcu = "journalctl --user";

    jcunit = "journalctl -xeu";
    jcuunit = "journalctl --user -xeu";
  };
in {
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (
        lib.mapAttrsToList
        (
          key: value: ''abbr "${key}"="${value}"''
        )
        aliases
      )
    );
  };
}
