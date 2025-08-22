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
    "d /srv/storage/music 0700 hnjae users -"
    ''f /srv/selfhost/readcache/CACHEDIR.TAG 0400 root root - "Signature: 8a477f597d28d172789f06886806bc55"''
  ];

  # 8 hexadecimal characters.
  # run `head -c4 /dev/urandom | od -A none -t x4`
  # `echo 'eris' | cksum | awk '{printf "%08x\n", $1}'`
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
              name = "ERIS_ESP_A";
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
            eris_a = {
              name = "ERIS_ZFS_A";
              size = "100%";
              content = {
                type = "zfs";
                pool = "eris";
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
              name = "ERIS_ESP_B";
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
            eris_b = {
              name = "ERIS_ZFS_B";
              size = "100%";
              content = {
                type = "zfs";
                pool = "eris";
              };
            };
          };
        };

      };
    };
    zpool = {
      eris = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [
                  "/dev/disk/by-partlabel/ERIS_ZFS_A"
                  "/dev/disk/by-partlabel/ERIS_ZFS_B"
                ];
              }
            ];
          };
        };

        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          compression = "zstd";
          recordsize = "64K";
          # special_small_blocks = "4K";
          xattr = "sa";
          redundant_metadata = "most"; # mirrored-vdevs
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

          # includes /tmp
          "local/rootfs" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
              recordsize = "16K";
              compression = "lz4";
            };
            postCreateHook = "zfs list -t snapshot -H -o name -- 'eris/local/rootfs' | grep -E '^eris/local/rootfs@blank$' || zfs snapshot eris/local/root@blank";
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
              # special_small_blocks = "64K";
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
              compression = "lz4";
            };
          };

          "safe/userhome" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae";
              recordsize = "16K";
              compression = "lz4";
            };
          };

          "local/usercache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.cache";
              recordsize = "16K";
              compression = "lz4";
            };
          };

          "local/usercontainers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/containers";
            };
          };

          "safe/selfhost" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/selfhost";
            };
          };
          # NOTE: 나중에 metadata special device 추가해서 분리할 때를 위해 분리 <2025-08-22>
          "safe/selfhost/slow" = {
            type = "zfs_fs";
            options = {
              compression = "zstd";
              recordsize = "128K";
            };
          };

          "safe/selfhost/fast" = {
            type = "zfs_fs";
            options = {
              compression = "lz4";
            };
          };

          "safe/selfhost/dblike" = {
            type = "zfs_fs";
            options = {
              atime = "off";
              primarycache = "metadata";
              recordsize = "16K";
              xattr = "sa";
              compression = "lz4";
            };
          };

          "safe/selfhost/readcache" = {
            type = "zfs_fs";
            options = {
              compression = "zle";
              recordsize = "1M";
            };
          };

          "safe/storage" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              recordsize = "1M";
              compression = "zstd";
            };
          };

          "safe/storage/music" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/storage/music";
              compression = "zle";
            };
          };
        };
      };
    };
  };
}
