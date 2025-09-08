{
  fileSystems = {
    "/persist".neededForBoot = true;
    "/secrets".neededForBoot = true;
  };

  /*
     NixOS 25.05:

    - 아래가 잘 작동하려면, stage1 에서 zfs 가 import/mount 되어야하는 듯.
    - `zfs.target` 은 `sysinit.target` 을 의존성으로 가지니 추가 X
    - stage 2 에서 import 하는 zfs pool 은 `zfs-import.target` 을 의존성으로 가지면 안됨.

    - target 은 wants 에 만 추가해도, 이것이 실행되어야 reached 에 도달하나? 다른 systemd 유닛 설정에는 전부 wantedby 만 추가되어 있다. before/after 지정은 아무도 안함.
  */
  systemd.targets.local-fs = {
    wants = [ "zfs-mount.service" ];
    # default after: local-fs-pre.target (NixOS 25.05)
    after = [
      "zfs-import.target"
    ];
  };

  /*
     NixOS 25.05:

    - `root` 가 disposable 하니, `/etc/vconsole.conf` 생성 전에 vconsole 설정이 완료되는 일이 생김.
    - `local-fs.target` 후에 서비스 시작하도록 함.
  */
  systemd.services.systemd-vconsole-setup.after = [ "local-fs.target" ];

  systemd.tmpfiles.rules = [
    # 아래는 이미 포함되어 있음.
    # "d /var/empty 0555 root root -"
    # "h /var/empty - - - - +i"

    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local 0700 hnjae users -"
    "d /home/hnjae/.local/share 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
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
            # initrd 가 은근히 커서 크게 잡음.
            ESP = {
              size = "4G";
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
            ZFS = {
              size = "1899G";
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
            SWAP = {
              size = "4G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
                mountOptions = [ "nofail" ];
                discardPolicy = "pages";
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
              size = "4G";
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
            ZFS = {
              size = "1899G";
              type = "a504";
              content = {
                type = "zfs";
                pool = "eris";
              };
            };
            SWAP = {
              size = "100%";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
                mountOptions = [ "nofail" ];
                discardPolicy = "pages";
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
              reservation = "379.8G";
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
          "untracked" = {
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
              reservation = "32G";
              # special_small_blocks = "64K";
            };
          };
          "local/varlib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              exec = "off";
            };
          };
          "local/varlib/sbctl" = {
            # secure boot
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/sbctl";
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

          "local/cache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/cache";
              compression = "off";
              exec = "off";
            };
          };

          "safe/varlib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              exec = "off";
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

          "safe/storage" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              exec = "off";
            };
          };

          "safe/storage/music" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/nfs/music";
              compression = "zle";
              recordsize = "64K";
            };
          };

          "safe/storage/vault" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/nfs/vault";
              compression = "zstd";
              recordsize = "1M";
            };
          };

          "safe/storage/rustic-local-head" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/rustic-local";
              compression = "off";
              recordsize = "1M";
            };
          };

          "safe/apps" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/srv/apps";
            };
          };

          ################
          # postgresql   #
          ################

          "safe/apps/postgresql" = {
            type = "zfs_fs";
            options = {
              primarycache = "metadata";
              recordsize = "16K";
              compression = "lz4";
              #     atime = "off";
              #     xattr = "sa";
            };
          };

          ################
          # garage       #
          ################

          "safe/apps/garage" = {
            type = "zfs_fs";
            options = { };
          };

          "safe/apps/garage/data" = {
            type = "zfs_fs";
            options = {
              compression = "zstd";
              recordsize = "1M";
            };
          };

          "safe/apps/garage/meta" = {
            type = "zfs_fs";
            options = {
              compression = "lz4";
              recordsize = "16k";
            };
          };

          ################
          # freshrss    #
          ################

          "safe/apps/freshrss" = {
            type = "zfs_fs";
            options = { };
          };

          "safe/apps/freshrss/freshrss" = {
            type = "zfs_fs";
            options = { };
          };

          "safe/apps/freshrss/postgresql" = {
            type = "zfs_fs";
            options = {
              primarycache = "metadata";
              recordsize = "16K";
              compression = "lz4";
              #     atime = "off";
              #     xattr = "sa";
            };
          };

          ################
          # readeck      #
          ################

          "safe/apps/readeck" = {
            type = "zfs_fs";
            options = { };
          };

          "safe/apps/readeck/readeck" = {
            type = "zfs_fs";
            options = {
              compression = "lz4";
            };
          };

          "safe/apps/readeck/postgresql" = {
            type = "zfs_fs";
            options = {
              primarycache = "metadata";
              recordsize = "16K";
              compression = "lz4";
              #     atime = "off";
              #     xattr = "sa";
            };
          };

          ################
          # seafile      #
          ################

          "safe/apps/seafile" = {
            type = "zfs_fs";
            options = { };
          };

          "safe/apps/seafile/mysql" = {
            type = "zfs_fs";
            options = {
              compression = "lz4";
              recordsize = "16K";
              primarycache = "metadata";
            };
          };

          # shared directory among seafile-related services (akin `/opt/seafile-data` in examples)
          "safe/apps/seafile/data" = {
            type = "zfs_fs";
            options = {
              compression = "zstd";
            };
          };

          ################
          # iason        #
          ################

          "safe/apps/iason" = {
            type = "zfs_fs";
            options = {
            };
          };

          "safe/apps/iason/config" = {
            type = "zfs_fs";
            options = {
              recordsize = "16K";
              compression = "lz4";
            };
          };

          "safe/apps/resources" = {
            type = "zfs_fs";
            options = {
              recordsize = "1M";
              compression = "zstd-6";
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
