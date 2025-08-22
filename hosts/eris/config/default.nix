{ lib, ... }:
{
  imports = [
    ./ssh-host-key.nix
    ./systemd.nix
  ];

  services.xserver.xkb = {
    # KVM 에서 copy-and-paste 하기 위해.
    layout = "us";
    variant = lib.mkForce "";
    # options = lib.mkForce "";
  };
}
