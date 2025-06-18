{ ... }:
{
  imports = [
    ./snapper.nix
  ];
  services.zfs.autoScrub.enable = true;

  services.fail2ban.enable = true;
}
