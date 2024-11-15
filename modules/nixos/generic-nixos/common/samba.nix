_: {
  # NOTE: man 5 smb.conf
  services.samba.settings = {
    global = {
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
