{
  lib,
  pkgs,
  ...
}:
let
  systemctlAliasSuffix = {
    lsu = "list-units";
    lsam = "list-automounts";
    lsp = "list-paths";
    lss = "list-sockets";
    lst = "list-timers";
    lsd = "list-dependencies";
    f = "--failed";
    st = "status";
    sh = "show";
    c = "cat";
    h = "help";
  };

  systemctlAliases = (
    lib.mapAttrs' (
      map: command: lib.nameValuePair ("sc${map}") ("systemctl ${command}")
    ) systemctlAliasSuffix
  );
  systemctlUserAliases = (
    lib.mapAttrs' (
      map: command: lib.nameValuePair ("scu${map}") ("systemctl --user ${command}")
    ) systemctlAliasSuffix
  );

  aliases = lib.mergeAttrsList [
    systemctlAliases
    systemctlUserAliases
    {
      sc = "systemctl";
      scu = "systemctl --user";

      scx = "sudo systemctl start";
      scux = "systemctl --user start";
      scrx = "sudo systemctl restart";
      scurx = "systemctl --user restart";
      scr = "sudo systemctl reload";
      scur = "systemctl --user reload";
      scsp = "sudo systemctl stop";
      scusp = "systemctl --user stop";
      sck = "sudo systemctl stop";
      scuk = "systemctl --user stop";
      scK = "sudo systemctl kill";
      scuK = "systemctl --user kill";

      jc = "journalctl";
      jcu = "journalctl --user";

      jcx = "journalctl -xeu";
      jcux = "journalctl --user -xeu";
    }
  ];
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    home.shellAliases = aliases;

    xdg.configFile."zsh-abbr/user-abbreviations".text = (
      lib.concatLines (lib.mapAttrsToList (key: value: ''abbr "${key}"="${value}"'') aliases)
    );
  };
}
