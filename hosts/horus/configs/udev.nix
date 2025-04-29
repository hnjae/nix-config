{ pkgs, ... }:
{
  # environment.systemPackages = with pkgs; [ hdparm ];

  # -S:
  # Set the standby (spindown) timeout for the drive. The timeout specifies how
  # long to wait in idle (with no disk activity) before turning off the motor to
  # save power. The value of 0 disables spindown, the values from 1 to 240
  # specify multiples of 5 seconds and values from 241 to 251 specify multiples
  # of 30 minutes.
  # -S 251: 350min (5h 50m)
  # -S 250: 320min (5h 20m)
  # -S 249: 290min (4h 50m)
  # -S 248: 260min (4h 20m)
  # -S 247: 230min (3h 50m)
  # -S 246: 200min (3h 20m)
  # -S 245: 170min (2h 50m)
  # -S 244: 140min (2h 20m)
  # -S 243: 110min (1h 50m)
  # -S 242:  80min (1h 20m)
  # -S 241:  50min
  # -S 240:  20min

  # 243 에서 위로는 변경하지 말 것. 관련되서 하드코딩 되어 있다. <2025-03-10>
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/sbin/hdparm -B 128 -S 245 /dev/%k"
  '';
}
