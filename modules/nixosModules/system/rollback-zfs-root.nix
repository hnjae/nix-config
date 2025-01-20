# NOTE: ${cfg.zfsRootPoolName}@blank 이 있어야 함.
/*
NOTE:
  * <https://www.freedesktop.org/software/systemd/man/latest/bootup.html>
  * <https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167/6>
*/
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.rollback-zfs-root;
in {
  options.rollback-zfs-root = {
    enable = lib.mkEnableOption "";

    rollbackDataset = lib.mkOption {
      type = lib.types.str;
      example = "isis/local/root@blank";
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: do I need this? <2025-01-19>
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "uas"
      "sd_mod"
    ];

    boot.initrd.systemd = {
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

          # 아래 두가지는 의미 없었음.
          # "initrd-root-device.target"
          # "zfs-import-isis.service"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          set -e
          zfs rollback -r ${cfg.rollbackDataset}
        '';
      };

      # services.debug = {
      #   wantedBy = [
      #     "initrd.target"
      #   ];
      #   after = [
      #     "sysroot.mount"
      #   ];
      #   before = ["initrd-fs.target"];
      #   unitConfig.DefaultDependencies = "no";
      #   serviceConfig.Type = "oneshot";
      #   script = ''
      #     systemctl list-units >/sysroot/abcd
      #     zfs list >/sysroot/abcd-zfs
      #   '';
      # };
    };
  };
}
