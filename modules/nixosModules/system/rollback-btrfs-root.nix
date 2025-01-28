/*
  README:
    Btrfs root 을 매번 초기화 하는 모듈
    persist (impermanence) 를 사용할 때 함께 사용
    ssh 를 이용한 luks-unlock 지원

  !: "@root-latest" subvolume 을 ROOT 으로 사용해야 한다.

  참고 링크:
    https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030
    https://mth.st/blog/nixos-initrd-ssh/
    https://github.com/NixOS/nixpkgs/issues/98741
    https://discourse.nixos.org/t/wireless-connection-within-initrd/38317/12
*/
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.rollback-btrfs-root;
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.rollback-btrfs-root = {
    enable = mkEnableOption "Rollback Btrfs root to empty state.";

    rootBlockDevice = mkOption {
      type = types.path;
      description = "OS-installed block device path.";
      example = "/dev/mapper/vg_xxx-lv_yyy";
    };

    luksSupport = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Unlock LUKS in initrd.";

          mappingName = mkOption {
            type = types.nonEmptyStr;
            description = "LUKS mapping name.";
            example = "luks-foo";
          };

          device = mkOption {
            type = types.path;
            description = "Block device path for LUKS backend.";
            example = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/";
          };
        };
      };
    };

    sshLuksUnlock = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Unlock LUKS via SSH in initrd.";

          networkKernelModule = mkOption {
            type = types.nonEmptyStr;
            description = "Kernel module for network interface.";
            example = "r8169";
          };

          networkInterfaceName = mkOption {
            type = types.nonEmptyStr;
            description = "Network interface name.";
            example = "eno1";
          };

          authorizedKeys = mkOption {
            type = types.nonEmptyListOf types.nonEmptyStr;
            description = "List of authorized keys for SSH in initrd.";
            example = [ "ssh-ed25519 xxxxxxxxxxxxxxxxxxxxxx" ];
          };
          hostKeys = mkOption {
            type = types.nonEmptyListOf types.path;
            description = "List of path of host keys for SSH in initrd.";
            example = [ "/persist/@/initrd-ssh-host-prviate" ];
          };

          port = mkOption {
            type = types.int;
            default = 2222;
            description = ''
              Port number for SSH in initrd.
              It is recommended to configure the different port with the OS port, as conflicts may occur in known hosts.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    boot.initrd = {
      kernelModules = lib.lists.optional (cfg.sshLuksUnlock.enable) cfg.sshLuksUnlock.networkKernelModule;

      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "uas"
        "sd_mod"
      ];

      services.lvm.enable = true;

      luks = lib.attrsets.optionalAttrs (cfg.luksSupport.enable) {
        forceLuksSupportInInitrd = true;
        devices."${cfg.luksSupport.mappingName}" = {
          device = cfg.luksSupport.device;
          preLVM = true;
        };
      };

      network = lib.attrsets.optionalAttrs (cfg.sshLuksUnlock.enable) {
        enable = true;
        ssh = {
          enable = true;
          inherit (cfg.sshLuksUnlock) port authorizedKeys hostKeys;
        };
      };

      systemd = (
        lib.mergeAttrsList [
          (lib.attrsets.optionalAttrs cfg.sshLuksUnlock.enable {
            users.root.shell = "/bin/systemd-tty-ask-password-agent";
            network = {
              enable = cfg.sshLuksUnlock.enable;
              networks."02-lan" = {
                matchConfig.Name = cfg.sshLuksUnlock.networkInterfaceName;
                networkConfig.DHCP = "yes";
              };
            };
          })
          {
            enable = true;

            initrdBin = with pkgs; [ e2fsprogs ];

            services.rollback = {
              description = "Restore Btrfs root subvolume to empty state";
              wantedBy = [
                "initrd.target"
              ];
              after =
                let
                  inherit (builtins) replaceStrings substring;
                  rootBlockDevUnitName =
                    (substring 1 (-1) (replaceStrings [ "-" "/" ] [ "\\x2d" "-" ] cfg.rootBlockDevice)) + ".device";
                in
                [
                  /*
                    e.g.)
                      "dev-mapper-vg_isis\\x2dlv_nixos.device"
                      systemd-cryptsetup@luks\x2dosiris.service
                  */
                  rootBlockDevUnitName
                ];
              before = [
                "sysroot.mount"
              ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                set -e

                TEMP_PATH="/btrfs_tmp"
                OLDROOT="$TEMP_PATH/@old-roots"
                FRESHROOT="$TEMP_PATH/@root-latest"

                [ ! -b ${cfg.rootBlockDevice} ] && echo "Can not find ${cfg.rootBlockDevice}." && exit 1

                mkdir -p "$TEMP_PATH"
                mount -o subvol=/ ${cfg.rootBlockDevice} "$TEMP_PATH"

                [ ! -d "$OLDROOT" ] && btrfs subvol create "$OLDROOT"

                if [ -e "$FRESHROOT" ]; then
                  timestamp=$(date -u -r "$FRESHROOT" "+%Y-%m-%dT%H:%M:%SZ")
                  mv "$FRESHROOT" "$OLDROOT/$timestamp"
                fi

                delete_subvolume_recursively() {
                  for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "$TEMP_PATH/$i"
                  done
                  btrfs subvolume delete "$1"
                }

                for i in $(find "$OLDROOT" -mindepth 1 -maxdepth 1 -mtime +21); do
                  delete_subvolume_recursively "$i"
                done

                btrfs subvolume create "$FRESHROOT"
                chattr +C -R "$FRESHROOT"

                umount "$TEMP_PATH"
                rmdir "$TEMP_PATH"
              '';
            };
          }
        ]
      );
    };
  };
}
