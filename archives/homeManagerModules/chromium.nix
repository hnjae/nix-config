{
  config,
  pkgs,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {enableWideVine = true;};
    extensions = [
      # vimium-c
      {
        id = "hfjbmagddngcpeloejdejnfgbamkjaeg";
      }
      # ublock origin
      {
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
      }
      # 1password
      {
        id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
      }
      # gnome-shell-integration
      # { id = "gphhapmejobijbbhgpjhcjognlahblep"; }
      # gcbommkclmclpchllfjekcdonpmejbdp
    ];
  };
  # home.packages = libadwaita;
}
