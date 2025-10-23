{
  networking.useDHCP = false;

  systemd.network = {
    enable = true;

    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };

    networks."10-lan" = {
      matchConfig.Name = [ "eno1" ];
      networkConfig = {
        Bridge = "br0";
      };
    };

    networks."10-lan-bridge" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "no";
        Gateway = "192.168.0.1";
        Address = "192.168.0.200/16";
        LLMNR = "resolve";
        MulticastDNS = true;
      };
    };

    #   # https://www.freedesktop.org/software/systemd/man/latest/systemd.network.html
    #   networks."10-lan" = {
    #     matchConfig = {
    #       Name = "eno1";
    #     };
    #     networkConfig = {
    #       DHCP = "no";
    #       Gateway = "192.168.0.1";
    #       Address = "192.168.0.200/16"; # `/16`: router의 subnetmask 설정 반영
    #
    #       # run `resolvectl status` to check
    #       LLMNR = "resolve";
    #       MulticastDNS = true; # avahi 필요함. 되었다가 안되었다가 함.
    #     };
    #   };
  };
}
