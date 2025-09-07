{

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      interval = "*-*-01 04:00:00";
      randomizedDelaySec = "5m";
      pools = [ "eris" ];
    };
  };
}
