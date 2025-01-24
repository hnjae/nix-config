{
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in
{
  imports = [ ./thunderbird.nix ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = builtins.concatLists [
      # email
      "com.getmailspring.Mailspring" # gpl3
    ];
  };
}
