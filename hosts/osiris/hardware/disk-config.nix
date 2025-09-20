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

  systemd.tmpfiles.rules = [
    "d /home/hnjae 0700 hnjae users -"
    "d /home/hnjae/.cache 0700 hnjae users -"
    "d /home/hnjae/.local/share/containers 0700 hnjae users -"
    "d /home/hnjae/.local/share/baloo 0700 hnjae users -"
    "d /home/hnjae/.local/share/flatpak 0755 hnjae users -"
    "R /home/hnjae/.local/share/flatpak/.Trash-1000 - - - - "
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

          ############
          # Optional #
          ############

          "local/var.lib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          "local/etc" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          "safe/var.lib" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          "local/etc/NetworkManager.system-connections" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/etc/NetworkManager/system-connections";
            };
          };

          "local/var.lib/AccountsService" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/AccountsService";
            };
          };
          "local/var.lib/bluetooth" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/bluetooth";
            };
          };
          "local/var.lib/containers" = {
            # NOTE: podman volume 은 ZFS 로 관리되지 않음. <2025-08-04>
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/containers";
            };
          };
          "local/var.lib/fprint" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/fprint";
            };
          };
          "local/var.lib/nixos" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/nixos";
            };
          };
          "local/var.lib/sbctl" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/sbctl";
            };
          };
          "local/var.lib/systemd.coredump" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/systemd/coredump";
            };
          };
          "local/var.lib/tailscale" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/tailscale";
            };
          };

          "safe/var.lib/libvirt" = {
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

          "local/user" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
            };
          };

          "local/user/cache" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.cache";
              recordsize = "16K";
            };
          };
          "local/user/baloo" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/baloo";
              recordsize = "16K";
            };
          };
          "local/user/containers" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/containers";
            };
          };
          "local/user/flatpak" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/home/hnjae/.local/share/flatpak";
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
