{
  imports = [
    ./backup-offsite.nix
    ./zrepl.nix
  ];

  services.zfs.autoScrub = {
    enable = true;
    pools = [ "osiris" ];
  };

  services.zfs.trim = {
    enable = true;
  };
}
