{
  config,
  lib,
  ...
}:
{
  sops.secrets.ssh-host-ed25519-key = {
    format = "binary";
    sopsFile = ./secrets/isis.ssh_host_ed25519_key;
    mode = "0400";
  };

  services.openssh.hostKeys = lib.mkForce [
    {
      path = config.sops.secrets.ssh-host-ed25519-key.path;
      type = "ed25519";
    }
  ];
}
