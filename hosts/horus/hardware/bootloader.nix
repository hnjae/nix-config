_: {
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.memtest86.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  boot.kernelParams = [
    # "nomodeset" # nomodeset 을 쓰면 gpu 가 제대로 동작하지 않는다.
    "text"
  ];
}
