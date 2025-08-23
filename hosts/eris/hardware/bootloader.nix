{
  pkgs,
  ...
}:
{
  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/persist/lanzaboote.pki-bundle";
  #   settings.console-mode = "keep"; # use vendor's firmware's default
  # };

  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
    };
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
