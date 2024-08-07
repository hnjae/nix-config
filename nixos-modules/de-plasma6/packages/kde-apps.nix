{pkgs, ...}: {
  programs = {
    partition-manager.enable = true;
    kde-pim = {
      enable = true;
      kmail = false;
      kontact = false;
      merkuro = true;
    };
    kdeconnect = {
      enable = true;
      # package = pkgs.kdePackages.kdeconnect-kde;
    };
  };

  environment.defaultPackages = with pkgs; [
    # kde-apps
    # libsForQt5.polkit-kde-agent
    # libsForQt5.kdeplasma-addons
    # libsForQt5.powerdevil
    # desktop sharing(vnc)
    # libsForQt5.krfb
  ];
}
