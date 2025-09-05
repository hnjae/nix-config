{
  imports = [
    ./seafile.nix
    ./systemd.nix
    ./wol.nix
  ];

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
