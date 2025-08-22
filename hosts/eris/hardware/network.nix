{
  networking.useDHCP = true;
  # systemd.network = {
  #   wait-online.enable = false;
  #   networks."10-lan" = {
  #     matchConfig = {
  #       Name = "foo";
  #     };
  #     networkConfig = {
  #       DHCP = "no";
  #       Gateway = "192.168.0.1";
  #       Address = "192.168.0.200";
  #
  #       # check `services.resolved`.  run `resolvectl status`
  #       LLMNR = "resolve";
  #       MulticastDNS = true;
  #     };
  #   };
  # };
  #
  # services.avahi.enable = false;
}
