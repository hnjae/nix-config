_: {
  imports = [
    ./dynamic-battery-charge-threshold
    ./fprint.nix
    ./ollama.nix
    ./zrepl.nix

    # ./tabby.nix
    # ./shairport-sync.nix

    # ./restic-backup
    ./rustic-backup
  ];

  # USB 를 autosuspend 해, 마우스 사용에 애로사항이 있음.
  # Tunnable 한 값을 직접, module-parameter, udev, sysctl 를 이용해서 설정하자.
  # powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
  };

  services.zfs.autoScrub = {
    enable = true;
    pools = [ "isis" ];
  };

  # 아래 켰을때, /persist 에 링크하기
  # services.fwupd.enable = true;

  virtualisation.waydroid.enable = false;

  # services.resilio = {
  #   enable = true;
  #   enableWebUI = true;
  # };
  #
  # environment.persistence."/persist" = {
  #   directories = [
  #     {
  #       directory = "/var/lib/resilio-sync";
  #       mode = "0700";
  #     }
  #   ];
  # };
}
