{ ... }:
{
  imports = [
    ./configs
    ./hardware
    ./services
  ];
  system.stateVersion = "24.11";
  base-nixos.role = "desktop";

  rollback-zfs-root = {
    enable = true;
    rollbackDataset = "isis/local/root@blank";
  };

  persist = {
    enable = true;
    isDesktop = true;
  };
}
