{
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.network.html
    networks."10-lan" = {
      matchConfig = {
        Name = "eno1";
      };
      networkConfig = {
        DHCP = "no";
        Gateway = "192.168.0.1";
        Address = "192.168.0.200/16"; # `/16`: router의 subnetmask 설정 반영

        # check `services.resolved`.  run `resolvectl status`
        LLMNR = "resolve";
        MulticastDNS = true; # avahi 필요함. 되었다가 안되었다가 함.
      };
    };
  };
}
