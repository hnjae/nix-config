{
  networking = {
    useDHCP = true;
    networkmanager.enable = false;
    defaultGateway = "192.168.0.1";
    interfaces.eno1.ipv4.addresses = [
      {
        address = "192.168.0.200";
        prefixLength = 16;
      }
    ];
  };
}
