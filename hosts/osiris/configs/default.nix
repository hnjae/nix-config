{
  nix.settings.min-free = "4G";

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
