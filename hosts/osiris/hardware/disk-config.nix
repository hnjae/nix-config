{
  fileSystems = {
    "/persist".neededForBoot = true;
    "/secrets".neededForBoot = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local/share/baloo 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
    "d /home/hnjae/.local/share/flatpak 0755 hnjae users -"
  ];

  # run `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "f648c215"; # for ZFS. hexadecimal characters.
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
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4ecd71f5";
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

          "local/rootfs" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
              recordsize = "16K";
            };
            postCreateHook = "zfs list -t snapshot -H -o name -- 'osiris/local/rootfs' | grep -E '^osiris/local/rootfs@blank$' || zfs snapshot osiris/local/rootfs@blank";
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
              quota = "256G";
              reservation = "64G";
              compression = "zstd";
            };
          };
          # Optional
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
            };
          };

          "local/usercache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.cache";
              recordsize = "16K";
            };
          };
          "local/userbaloo" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/baloo";
              recordsize = "16K";
            };
          };
          "local/usercontainers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/containers";
            };
          };
          "local/userflatpak" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/flatpak";
            };
          };
        };
      };
    };
  };
}
