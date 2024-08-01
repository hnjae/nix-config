{...}: {
  services.samba = {
    extraConfig = ''
      # charset, naming
      # mangled names = illegal
      unix extensions = no
      case sensitive = yes
      # preserve case = yes
      # short preserve care = yes
      # default case = upper

      #
      # hide dot files = no
      # hide special files = no
      # hide files = no
      # hide unreadable = no

      # do not inherit permission from parent directory
      inherit permissions = no
      store dos attributes = no

      block size = 4096

      create mask = 0644
      directory mask = 0755
      guest ok = no
    '';
  };
}
