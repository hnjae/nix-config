{ lib, ... }:
{
  imports = [
    ./ssh-host-key
    ./systemd.nix
  ];

  services.xserver.xkb = {
    # KVM 에서 copy-and-paste 하기 위해, qwerty 사용
    layout = "us";
    variant = lib.mkForce "";
    options = lib.mkForce (
      builtins.concatStringsSep "," [
        "caps:backspace"
      ]
    );
  };

  boot.kernel.sysctl = {
    "vm.overcommit_memory" = 1; # redis
  };

}
