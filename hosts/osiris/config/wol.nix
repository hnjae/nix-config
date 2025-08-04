{
  # run `ethtool enp7s0 | grep Wake-on`
  networking.interfaces.enp7s0.wakeOnLan = {
    policy = [
      "magic"
    ];
    enable = true;
  };
}
