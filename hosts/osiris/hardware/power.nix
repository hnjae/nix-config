{ pkgs, ... }:
{
  boot.kernelParams = [
    "nohibernate"
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  powerManagement.scsiLinkPolicy = "med_power_with_dipm";

  # TODO:
  # ACTION=="add", SUBSYSTEM=="net", NAME=="en*", RUN+="/usr/bin/ethtool -s $name wol g"
  services.udev.extraRules = ''
    # Wake on lan
    ACTION=="add", SUBSYSTEM=="net", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"

    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"

    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 248 /dev/%k"

    ###########################
    # Individual Device Rules #
    ###########################
    # Logivolt
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    # Kensington Orbit Trackball
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="2822", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    # Keyboard using VIA
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{manufacture}=="VIA Labs*", ATTR{power/wakeup}="enabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    ###############################
    # Generic IO USB Device Rules #
    ###############################
    # Disable wake on USB Mouse
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*Mouse*", ATTR{power/wakeup}="disabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    # USB Keyboard
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{product}=="*Keyboard*", ATTR{power/wakeup}="enabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    # Bluetooth Radio
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{product}=="Bluetooth Radio", ATTR{power/wakeup}="enabled", ATTR{power/autosuspend}="-1", ATTR{power/control}="on"

    ###########################
    # Generic USB Device      #
    ###########################
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  '';
  # power/autosuspend 는 suspend 까지 걸리는 시간인듯.

  # NOTE: 248 = 4 hours
}
