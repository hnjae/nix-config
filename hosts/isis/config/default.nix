{
  imports = [
    ./nameserver-encrypted.nix
    ./pipewire.nix
    ./ssh-host-key
    ./systemd.nix
  ];

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
