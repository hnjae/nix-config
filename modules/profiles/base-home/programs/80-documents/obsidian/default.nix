{
  pkgs,
  config,
  lib,
  ...
}:
let
  baseHomeCfg = config.base-home;

  /*
    <https://flathub.org/apps/md.obsidian.Obsidian>

    LICENSE:
      - <https://help.obsidian.md/teams/license>
      - <https://obsidian.md/blog/free-for-work/?ref=creativerly.com>
  */
  appId = "md.obsidian.Obsidian";

in
{
  imports = [
    ./obsidian-nvim.nix
  ];

  config = lib.mkIf (baseHomeCfg.isDesktop && pkgs.config.allowUnfree) {

    default-app.fromApps = [ appId ];
    services.flatpak.packages = [ appId ];

    services.flatpak.overrides."${appId}" = {
      Context = {
        sockets = [ "wayland" ];
      };
    };

    xdg.dataFile."applications/${appId}.desktop" =
      let
        flags = [
          # enable wayland
          "--ozone-platform-hint=auto"
          "--enable-features=UseOzonePlatform"

          # enable text-input-v3
          "--enable-wayland-ime"
          "--wayland-text-input-version=3"
        ];
        flagStr = builtins.concatStringsSep " " flags;
      in
      {
        text = ''
          [Desktop Entry]
          Name=Obsidian
          Exec=flatpak run --branch=stable --arch=${pkgs.stdenv.hostPlatform.linuxArch} --command=obsidian.sh --file-forwarding md.obsidian.Obsidian ${flagStr} @@u %U @@
          Terminal=false
          Type=Application
          Icon=md.obsidian.Obsidian
          StartupWMClass=obsidian
          Comment=Obsidian
          MimeType=x-scheme-handler/obsidian;
          Categories=Office;
          X-Flatpak-Tags=proprietary;
          X-Flatpak=md.obsidian.Obsidian
        '';
      };
  };

}
