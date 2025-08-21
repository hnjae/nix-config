{
  imports = [
    ./nameserver-encrypted.nix
    ./pipewire.nix
    ./ssh-host-key.nix
    ./systemd.nix
  ];

  nix.settings.min-free = "4G";

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
  };
}
