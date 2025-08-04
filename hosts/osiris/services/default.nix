{
  imports = [
  ];

  services.zfs.autoScrub = {
    enable = true;
    pools = [ "osiris" ];
  };
}
