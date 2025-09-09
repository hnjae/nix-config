{
  config,
  pkgs,
  lib,
  ...
}:
{
  console = {
    earlySetup = false; # Disable virtual console setup in initrd.
    useXkbConfig = true; # use xkbOptions in tty.
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
  };

  #############################
  # vconsole fixed            #
  #############################
  /*
     NixOS 25.05 기준:
      - `/etc/vconsole.conf` 는 initrd-nixos-activation.service 에 의해 생성.
      - `systemd-udev-settle.service` 를 추가하여, GPU 를 setup 하고 vconsole 을 설정하도록 함.
  */
  systemd.services.systemd-vconsole-setup = lib.mkIf (!config.services.kmscon.enable) {
    wants = [
      "systemd-udev-settle.service"
    ];
    after = [
      "systemd-udev-settle.service"
    ];
  };

  services.kmscon = {
    # NOTE: kmscon 쓰면 greetd 호출이 늦어짐.<NixOS 23.05>
    enable = false && !config.services.greetd.enable;

    hwRender = true;
    extraConfig = ''
      xkb-layout=${config.services.xserver.xkb.layout}
      xkb-variant=${config.services.xserver.xkb.variant}
      xkb-options=${config.services.xserver.xkb.options}
      font-dpi=192
    '';

    # NOTE: fonts 옵션 넣으면 동작 안함. <2023-06-14>
    # fonts = [{
    #   name = "MesloLGM Nerd Font Mono";
    #   package = pkgs.nerdfonts.override { fonts = [ "Meslo" ]; };
    # }];
  };
}
