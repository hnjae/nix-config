{
  imports = [
    ./zfs-replication.nix
  ];

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      interval = "*-*-01 04:00:00";
      randomizedDelaySec = "5m";
      pools = [ "eris" ];
    };
  };

  # services.fail2ban.enable = true; # 사용하니 ssh 를 그냥 막아버리는데?
}
