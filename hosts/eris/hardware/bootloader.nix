{
  pkgs,
  ...
}:
{
  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
    };
    # # NOTE: lanzaboote replace the systemd-boot module
    # systemd-boot = {
    #   enable = true;
    #   memtest86.enable = true;
    # };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  environment.systemPackages = [
    # for secure-boot
    pkgs.sbctl
  ];
}
