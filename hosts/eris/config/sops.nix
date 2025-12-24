{ lib, ... }:
{
  sops.age = {
    keyFile = lib.mkForce "/zlocal/home-age-private";
    sshKeyPaths = [ ];
    generateKey = false;
  };

  systemd.tmpfiles.rules = [
    "z /zlocal/home-age-private 0400 root root - -"
  ];
}
