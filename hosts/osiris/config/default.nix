{
  imports = [
    ./wol.nix
    ./systemd.nix
  ];

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
