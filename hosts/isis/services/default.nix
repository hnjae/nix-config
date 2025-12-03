{
  imports = [
    ./dynamic-battery-charge-threshold
    ./fprint.nix
    ./ollama.nix
    ./systemd-mounts.nix
    ./systemd-resolved-encrypted.nix
    ./zfs-snapshot.nix

    # ./zrepl.nix
    # ./tabby.nix
    # ./shairport-sync.nix
    # ./backup-offsite.nix
  ];

  # USB 를 autosuspend 해, 마우스 사용에 애로사항이 있음.
  # Tunnable 한 값을 직접, module-parameter, udev, sysctl 를 이용해서 설정하자.
  # powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = true;

  services.zfs = {
    trim.enable = true;
    autoScrub = {
      enable = true;
      pools = [ "isis" ];
    };
  };

  virtualisation.waydroid.enable = false;
}
