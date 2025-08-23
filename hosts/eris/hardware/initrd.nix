/*
  NOTE:
    * <https://www.freedesktop.org/software/systemd/man/latest/bootup.html>
    * <https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/6>
*/
{
  config,
  self,
  pkgs,
  ...
}:
{
  boot.initrd = {
    availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"

      "r8169" # network drive. run `lsmod` to list loaded kernel modules
    ];
    systemd = {
      enable = true;

      initrdBin = with pkgs; [
        zfs
      ];

      services.rollback = {
        description = "Restore ZFS root dataset to empty state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "zfs-import.target"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          set -e
          zfs rollback -r -- 'eris/local/rootfs@blank'
        '';
      };

      network = {
        enable = true;
        networks."10-lan" = config.systemd.network.networks."10-lan";
      };
    };

    # network = {
    #   enable = false;
    #   ssh = {
    #     enable = true;
    #     authorizedKeys = [
    #       self.shared.keys.ssh.home
    #     ];
    #     hostKeys = [
    #       config.sops.secrets.ssh-host-ed25519-key.path
    #     ];
    #   };
    # };
  };
}
#   postCommands = ''
#   zpool import -a
#   echo "zfs load-key -a; killall zfs" >> /root/.profile
# '';
