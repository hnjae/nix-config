# l2arc_exclude_special
{
  fileSystems = {
    "/persist".neededForBoot = true;
    "/secrets".neededForBoot = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
  ];

  # 8 hexadecimal characters.
  # run `head -c4 /dev/urandom | od -A none -t x4`
  # `echo 'atum' | cksum | awk '{printf "%08x\n", $1}'`
  networking.hostId = "eed1b792"; # for ZFS. hexadecimal characters.
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.containers.storage.settings.storage.driver = "zfs";
  home-manager.sharedModules = [
    {
      /*
        NOTE: <2024-11-28>
          zfs is not supported in rooltless podman
          https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md
      */
      xdg.configFile."containers/storage.conf" = {
        # podman config
        text = ''
          [storage]
          driver = "overlay"
        '';
      };
    }
  ];

  disko.devices = {
    disk = {
      a = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_xxxxxxxxxxxxxxxxxxxxxx";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ATUM_ESP_A";
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
            swap_a = {
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 1;
              };
            };
            atum_a = {
              name = "ATUM_ZFS_A";
              size = "100%";
              content = {
                type = "zfs";
                pool = "atum";
              };
            };
          };
        };
      };
      b = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_xxxxxxxxxxxxxxxxxxxxxx";
        content = {
          type = "gpt";
          partitions = {
            esp_b = {
              name = "ATUM_ESP_B";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                # TODO: /boot 동기화 <2025-08-20>
                mountpoint = "/boot_fallback";
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
            swap_b = {
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 1;
              };
            };
            atum_b = {
              name = "ATUM_ZFS_B";
              size = "100%";
              content = {
                type = "zfs";
                pool = "atum";
              };
            };
          };
        };

      };
    };
    zpool = {
      atum = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "/dev/disk/by-partlabel/ATUM_ZFS_A"
                  "/dev/disk/by-partlabel/ATUM_ZFS_B"
                ];
              }
            ];
          };
        };

        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          compression = "lz4";
          recordsize = "64K";
          special_small_blocks = "4K";
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
          "local/rootfs" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
              recordsize = "16K";
            };
            postCreateHook = "zfs list -t snapshot -H -o name -- 'atum/local/rootfs' | grep -E '^atum/local/rootfs@blank$' || zfs snapshot atum/local/root@blank";
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
              recordsize = "64K";
              special_small_blocks = "64K";
            };
          };
          "local/containers" = {
            type = "zfs_fs";
            options = {
              # NOTE: podman volume 은 ZFS 로 관리되지 않음. <2025-08-04>
              mountpoint = "/var/lib/containers";
            };
          };
          "safe/libvirt" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/libvirt";
              recordsize = "16K";
            };
          };
          "safe/userhome" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae";
              recordsize = "16K";
            };
          };
          "local/usercache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.cache";
              recordsize = "16K";
            };
          };
          "local/usercontainers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/containers";
            };
          };
        };
      };
    };
  };
}
