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
          zfs rollback -r -- 'atum/local/rootfs@blank'
        '';
      };

      network = {
        enable = true;
        config = {

        };
        networks = {

        };
      };
    };

    network = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = [ ];
      };
    };
  };
}
