{ lib, ... }:
{
  # https://www.jeffgeerling.com/blog/2024/macos-finder-still-bad-network-file-copies
  # vfs objects catia fruit streams_xttar
  # fruit:nfs_aces no
  # NOTE: man 5 smb.conf
  services.samba.settings = {
    global = {
      "hosts allow" = lib.mkDefault (
        builtins.concatStringsSep " " [
          "10.0.0.0/8"
          "172.16.0.0/12" # 172.[16-31]
          "192.168.0.0/16"
          "100.64.0.0/10" # 100.[64-127]
          "127.0.0.1"
          "localhost"
        ]
      );
      "hosts deny" = lib.mkDefault "0.0.0.0/0";
      "printable" = lib.mkDefault "no";

      # charset, naming
      # "mangled names" = "illegal"; # defaults
      "case sensitive" = "yes";
      # "preserve case" = "yes"; # defaults
      # "short preserve care" = "yes"; # defaults
      # "default case" = "upper"; # defaults

      #
      # hide dot files = no
      # hide special files = no
      # hide files = no
      # hide unreadable = no

      #
      # do not inherit permission from parent directory
      "inherit permissions" = "no";

      #
      "smb1 unix extensions" = "no"; # supports symbolic links, hard links ...
      "smb3 unix extensions" = "no";
      "store dos attributes" = "no"; # read DOS attributes from xattr

      #
      "block size" = 4096; # default 1024 <NixOS 24.05>

      #
      "create mask" = "0644";
      "directory mask" = "0755";

      #
      "guest ok" = "no";
    };
  };
}
