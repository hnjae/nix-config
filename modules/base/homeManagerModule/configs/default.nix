{ ... }:
{
  imports = [
    ./default-app.nix
    ./desktop-entries.nix
    ./home.nix
    ./systemd.nix
    ./tmpfiles.nix
    ./xdg.nix
  ];
}
