{
  imports = [
    ./packages.nix
    ./pipewire.nix
    ./seafile.nix
    ./ssh-host-key
    ./systemd.nix
  ];

  #############################
  # vconsole fixed            #
  #############################
  # `/etc/vconsole.conf` 는 initrd-nixos-activation.service 에 의해 생성되어서, local-fs.target 과 관계 없음.
  # NOTE: systemd-udev-settle 를 추가하니, amdgpu 가 stage2 에서 인식되고, 화면 조정 후, vconsole 이 로드 되는 듯.
  systemd.services.systemd-vconsole-setup = {
    wants = [
      "systemd-udev-settle.service"
    ];
    after = [
      "systemd-udev-settle.service"
    ];
  };

  # systemd.services.display-manager = {
  #   wants = [
  #     "systemd-vconsole-setup.service"
  #   ];
  #   after = [
  #     "systemd-vconsole-setup.service"
  #   ];
  # };

  # systemd.services.reload-systemd-vconsole-setup = {
  #   wants = [
  #     "systemd-vconsole-setup.service"
  #   ];
  #   after = [
  #     "systemd-vconsole-setup.service"
  #   ];
  # };
}
