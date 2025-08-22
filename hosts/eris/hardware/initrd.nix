# NOTE: ${cfg.zfsRootPoolName}@blank 이 있어야 함.
/*
  NOTE:
    * <https://www.freedesktop.org/software/systemd/man/latest/bootup.html>
    * <https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/6>
*/
{
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
        enable = false;
        config = {

        };
        networks = {

        };
      };
    };

    # network = {
    #   ssh = {
    #     enable = true;
    #     authorizedKeys = [ ];
    #   };
    # };
  };
}
