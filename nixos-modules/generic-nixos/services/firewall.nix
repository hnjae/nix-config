{lib, ...}: {
  # networking.nftables.enable = lib.mkOverride 999 true;

  networking.firewall.enable = lib.mkOverride 999 true;
}
