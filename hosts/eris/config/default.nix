{ lib, ... }:
{
  imports = [
    ./ssh-host-key.nix
    ./systemd.nix
  ];

  services.xserver.xkb = {
    # managed by kvm
    layout = "us";
    variant = lib.mkForce "";
    options = lib.mkForce "";
  };
}
