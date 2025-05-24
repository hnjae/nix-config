{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseHomeCfg = config.base-home;
  inherit (lib.lists) optionals;
in
{
  imports = [ ./thunderbird.nix ];

  config = lib.mkIf (baseHomeCfg.isDesktop) {
    services.flatpak.packages = [
      # email
      # "com.getmailspring.Mailspring" # gpl3
      # "org.claws_mail.Claws-Mail"

      "io.github.alescdb.mailviewer" # .eml .msg viewer
    ];

    home.packages = with pkgs; [
      # https://github.com/LukeSmithxyz/mutt-wizard
      mutt-wizard
      neomutt
      isync
      msmtp
      pass
      # ca-certificates
      gettext
      goimapnotify
      # pam-gnupg
      lynx
      notmuch
      abook
      # urlview
    ];
  };
}
