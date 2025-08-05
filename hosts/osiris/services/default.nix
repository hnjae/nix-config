{
  imports = [
    ./backup-offsite
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
