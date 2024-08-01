{...}: {
  imports = [
    ./locate.nix
    ./ssh.nix
    ./firewall.nix
    ./containers.nix
    ./gnupg.nix
    ./libvirtd.nix
    ./polkit.nix
    ./fstrim.nix
    ./nix-managing.nix
    ./chrony.nix
    ./printing.nix
    ./upower.nix
    ./xserver.nix
    ./dbus.nix
    ./resolve.nix
    ./samba.nix
  ];
}
