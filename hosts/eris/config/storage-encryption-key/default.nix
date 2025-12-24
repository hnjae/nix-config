{
  sops.secrets.storage-encryption-key = {
    format = "binary";
    sopsFile = ./secrets/key;
    mode = "0400";
    path = "/etc/cryptsetup-keys.d/storage-encryption.key";
  };
}
