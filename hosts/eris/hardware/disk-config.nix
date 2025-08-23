{
  fileSystems = {
    "/persist".neededForBoot = true;
    "/secrets".neededForBoot = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local 0700 hnjae users -"
    "d /home/hnjae/.local/share 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
    "d /srv/storage/music 0700 hnjae users -"
    ''f /srv/selfhost/readcache/CACHEDIR.TAG 0444 root root - "Signature: 8a477f597d28d172789f06886806bc55"''
  ];

  # 8 hexadecimal characters.
  # run `head -c4 /dev/urandom | od -A none -t x4`
  # `echo 'eris' | cksum | awk '{printf "%08x\n", $1}'`
  networking.hostId = "5508701d"; # for ZFS. hexadecimal characters.
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
      ERIS_A = {
        type = "disk";
        # NVMe Future
        device = "/dev/disk/by-id/nvme-nvme.1e4b-3330313632333433393236-48532d5353442d465554555245203430393647-00000001";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
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
            SWAP = {
              size = "4G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 1;
              };
            };
            ZFS = {
              size = "1904G";
              type = "a504";
              content = {
                type = "zfs";
                pool = "eris";
              };
            };
            LVM = {
              size = "100%";
              type = "8E00";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };

      ERIS_B = {
        type = "disk";
        # NVMe SPCC
        device = "/dev/disk/by-id/nvme-nvme.10ec-323330303530373435313531303139-53504343204d2e32205043496520535344-00000001";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
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
            SWAP = {
              size = "4G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 1;
              };
            };
            ZFS = {
              size = "100%";
              type = "a504";
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
                  # PART LABEL
                  "/dev/disk/by-partlabel/disk-ERIS_A-ZFS"
                  "/dev/disk/by-partlabel/disk-ERIS_B-ZFS"
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
          "reserved" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "378G";
            };
          };
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
            postCreateHook = "zfs list -t snapshot -H -o name -- 'eris/local/rootfs' | grep -E '^eris/local/rootfs@blank$' || zfs snapshot eris/local/rootfs@blank";
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
              # special_small_blocks = "64K";
            };
          };
          "local/varlib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };
          "local/varlib/containers" = {
            type = "zfs_fs";
            options = {
              # NOTE: podman volume 은 ZFS 로 관리되지 않음. <2025-08-04>
              mountpoint = "/var/lib/containers";
            };
          };
          "local/varlib/nixos" = {
            # keep uid/gid of auto-generated users (e.g. avahi)
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/nixos";
            };
          };
          "local/varlib/systemd.coredump" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/systemd/coredump";
              compression = "zstd-6";
            };
          };
          "local/varlib/tailscale" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/tailscale";
            };
          };

          "safe/varlib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          "safe/varlib/libvirt" = {
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

          "local/user/cache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.cache";
              recordsize = "16K";
              compression = "lz4";
            };
          };

          "local/user/containers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/containers";
            };
          };

          "safe/selfhost" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          # NOTE: 나중에 metadata special device 추가해서 분리할 때를 위해 분리 <2025-08-22>
          "safe/selfhost/slow" = {
            type = "zfs_fs";
            options = {
              compression = "zstd";
              mountpoint = "/srv/selfhost/slow";
            };
          };

          "safe/selfhost/fast" = {
            type = "zfs_fs";
            options = {
              compression = "lz4";
              mountpoint = "/srv/selfhost/fast";
            };
          };

          "safe/selfhost/dblike" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/selfhost/dblike";
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
              mountpoint = "/srv/selfhost/readcache";
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

  environment.persistence."/persist/@" = {
    hideMounts = true;
    enableWarnings = false;
    files = [
      "/etc/machine-id"
    ];
    directories = [
      {
        # NOTE: /var/log 를 zfs dataset 으로 관리하면 poweroff 할때 unmount fail issue 뜸. <2025-08-23>
        directory = "/var/log";
        mode = "0755";
      }
    ];
  };

  # Use FS feature insteaad
  nix.settings.compress-build-log = false;
  hardware.firmwareCompression = "none";
}
