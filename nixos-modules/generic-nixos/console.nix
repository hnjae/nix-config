{
  config,
  pkgs,
  lib,
  ...
}: {
  console = {
    # Enable setting virtual console options in initrd.
    earlySetup = lib.mkOverride 999 true;
    # earlySetup = false;
    useXkbConfig = true; # use xkbOptions in tty.

    # font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";

    # font option does not work in NixOS 23.11
    # https://github.com/NixOS/nixpkgs/issues/274545
    # https://github.com/NixOS/nixpkgs/issues/257904
    # font = "latarcyrheb-sun32";
    # font = "ter-132n";
    # packages = with pkgs; [kbd terminus_font]; # for fonts
    # packages = with pkgs; [kbd]; # for fonts
  };

  services.kmscon = {
    # NOTE: kmscon 쓰면 greetd 호출이 늦어짐.<NixOS 23.05>
    enable = false && ! config.services.greetd.enable;

    hwRender = true;
    extraConfig = ''
      xkb-layout=${config.services.xserver.xkb.layout}
      xkb-variant=${config.services.xserver.xkb.variant}
      xkb-options=${config.services.xserver.xkb.options}
      font-dpi=168
    '';

    # NOTE: fonts 옵션 넣으면 동작 안함. <2023-06-14>
    # fonts = [{
    #   name = "MesloLGM Nerd Font Mono";
    #   package = pkgs.nerdfonts.override { fonts = [ "Meslo" ]; };
    # }];
  };
}
