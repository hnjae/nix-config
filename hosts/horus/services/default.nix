{ ... }:
{
  imports = [
    ./sanoid.nix
  ];
  services.zfs.autoScrub.enable = true;
}
