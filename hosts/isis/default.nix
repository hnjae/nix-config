{...}: {
  imports = [
    ./configs
    ./hardware
    ./services
  ];

  system.stateVersion = "24.11";
  generic-nixos.role = "desktop";

  persist = {
    enable = true;
    isDesktop = true;
  };

  rollback-zfs-root = {
    enable = true;
    rollbackDataset = "isis/local/root@blank";
  };
}
