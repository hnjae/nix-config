{pkgs, ...}: {
  programs = {
    partition-manager.enable = true;
    kde-pim = {
      enable = true;
      kmail = true;
      kontact = true;
      merkuro = true;
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
