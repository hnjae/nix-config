{
  config,
  lib,
  ...
}: {
  security.pam.services = let
    enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;
    enableKwallet = config.services.desktopManager.plasma6.enable;
  in
    builtins.mapAttrs
    (_: _: {
      inherit enableGnomeKeyring enableKwallet;
    })
    (lib.attrsets.filterAttrs (_: v: v.isNormalUser) config.users.users);
}
