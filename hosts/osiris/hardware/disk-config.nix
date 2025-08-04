{
  fileSystems = {
    "/persist".neededForBoot = true;
    "/secrets".neededForBoot = true;
  };

  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_HS_2000GB_23011N802482";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "OSIRIS_ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "nofail"
                  "noatime"
                  "nodev"
                  "nosuid"
                  "noexec"
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            osiris = {
              name = "OSIRIS_ZFS";
              size = "100%";
              content = {
                type = "zfs";
                pool = "osiris";
              };
            };
          };
        };
      };
    };
    zpool = {
      osiris = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          compression = "lz4";
          recordsize = "64K";
          xattr = "sa";
          # --
          atime = "off";
          relatime = "off";
          # --
          canmount = "off";
          mountpoint = "none";
          # --
          casesensitivity = "sensitive";
          normalization = "none";
          utf8only = "off";
          # --
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          #keylocation = "file:///tmp/secret.key";
          keylocation = "prompt";
        };
        options = {
          ashift = "12";
          autotrim = "off";
          compatibility = "off";
          # --
        };
        datasets = {
          "local" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };
          "safe" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
            };
            postCreateHook = "zfs list -t snapshot -H -o name -- 'osiris/local/root' | grep -E '^osiris/local/root@blank$' || zfs snapshot osiris/local/root@blank";
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "legacy";
              recordsize = "16K";
            };
          };
          "safe/secrets" = {
            type = "zfs_fs";
            mountpoint = "/secrets";
            options = {
              mountpoint = "legacy";
            };
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
            };
          };
          "local/containers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/containers";
              recordsize = "128K";
            };
          };
          "safe/home" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
