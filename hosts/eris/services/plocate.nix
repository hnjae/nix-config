{ pkgs, ... }:
{
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "never";
    prunePaths = [
      "/bin"
      "/boot"
      "/dev"
      "/nix"
      "/proc"
      "/root"
      "/run"
      "/srv"
      "/sys"
      "/tmp"
      "/usr"
      "/var"
      "/mnt"
      #
      "/secrets"
      "/persist"
    ];
    # output = "/srv/cache/locatedb";
  };
}
