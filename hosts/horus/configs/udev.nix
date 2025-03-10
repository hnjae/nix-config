{ pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [ hdparm ];

  # -S:
  # Set the standby (spindown) timeout for the drive. The timeout specifies how
  # long to wait in idle (with no disk activity) before turning off the motor to
  # save power. The value of 0 disables spindown, the values from 1 to 240
  # specify multiples of 5 seconds and values from 241 to 251 specify multiples
  # of 30 minutes.
  # -S 251: 320min (5h 20m)
  # -S 245: 170min
  # -S 244: 140min
  # -S 243: 110min
  # -S 242: 80min

  # 243 에서 위로는 변경하지 말 것. 관련되서 하드코딩 되어 있다. <2025-03-10>
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 243 /dev/%k"
  '';
}
