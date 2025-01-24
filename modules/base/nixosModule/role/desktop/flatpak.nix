{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.base-nixos.role == "desktop") {
    services.flatpak.enable = lib.mkOverride 999 true;

    # https://bbs.archlinux.org/viewtopic.php?id=261143
    # Whether to create a directory with links to all fonts in /run/current-system/sw/share/X11/fonts.
    fonts.fontDir.enable = lib.mkOverride 999 true;

    # NOTE: and symlink of following to use fonts/icon in flatpak apps
    systemd.tmpfiles.rules = lib.lists.optionals config.services.flatpak.enable [
      "L /usr/share/icons - - - - /run/current-system/sw/share/icons"
      "L /usr/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
    ];
    # "L /usr/share/mime - - - - /run/current-system/sw/share/mime"

    home-manager.sharedModules = lib.mkIf (config.services.flatpak.enable) [
      {
        # ~/.local/share/flatpak/overrides
        services.flatpak.overrides = {
          "global" = {Context = {filesystems = ["/nix/store:ro"];};};
        };
      }
    ];
  };
}
