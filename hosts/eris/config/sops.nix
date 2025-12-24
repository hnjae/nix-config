{ lib, ... }:
{
  sops.age = {
    keyFile = lib.mkForce "/zlocal/home-age-private";
    sshKeyPaths = [ ];
    generateKey = false;
  };
}
