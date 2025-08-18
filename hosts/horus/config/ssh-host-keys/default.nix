{
  config,
  self,
  lib,
  ...
}:
{
  sops.secrets.ssh-host-key-prv = {
    format = "binary";
    sopsFile = ./secrets/horus.ssh_host_ed25519_key;
    path = "/etc/ssh/ssh_host_ed25519_key";
    # path = "/proc/_openssh-hostkeys/ssh_host_ed25519_key";
    mode = "0400";
  };

  environment.etc."ssh/ssh_host_ed25519_key.pub" = {
    text = self.constants.hosts.horus.sshPublicKey;
    mode = "0644";
  };

  services.openssh.hostKeys = lib.mkForce [
    {
      path = config.sops.secrets.ssh-host-key-prv.path;
      type = "ed25519";
    }
    # {
    #   bits = 4096;
    #   path = "/etc/ssh/ssh_host_rsa_key";
    #   # path = "/persist/_openssh-hostkeys/ssh_host_rsa_key";
    #   type = "rsa";
    # }
  ];
}
