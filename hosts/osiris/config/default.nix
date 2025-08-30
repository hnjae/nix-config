{
  imports = [
    ./wol.nix
    ./power.nix
  ];

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
