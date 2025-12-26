/*
  NOTE:

  NixOS 25.11 기준

  `${pkgs.util-linux}/lib/systemd/system/fstrim.service` 파일 사용

  util-linux 2.41.2 내용:

  ```
  [Unit]
  Description=Discard unused blocks on filesystems from /etc/fstab
  Documentation=man:fstrim(8)
  ConditionVirtualization=!container

  [Service]
  Type=oneshot
  ExecStart=/nix/store/3r64xapzb469cnb5ggpd2gpjqxc1jwcc-util-linux-2.41.2-bin/sbin/fstrim --listed-in /etc/fstab:/proc/self/mountinfo --verbose --quiet-unsupported
  PrivateDevices=no
  PrivateNetwork=yes
  PrivateUsers=no
  ProtectKernelTunables=yes
  ProtectKernelModules=yes
  ProtectControlGroups=yes
  MemoryDenyWriteExecute=yes
  SystemCallFilter=@default @file-system @basic-io @system-service
  ```
*/
{
  services.fstrim = {
    enable = true;
  };
}
