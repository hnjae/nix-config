{ config, ... }:
{
  sops.secrets.ssh-host-key-prv = {
    format = "binary";
    sopsFile = ./secrets/horus.ssh_host_ed25519_key;
    mode = "0400";
  };

  services.openssh.hostKeys = [
    {
      path = config.sops.secrets.ddclient-config.path;
      type = "ed25519";
    }
    # {
    #   path = "/etc/ssh/ssh_host_ed25519_key";
    #   type = "ed25519";
    # }
    {
      bits = 4096;
      path = "/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
  ];
}
