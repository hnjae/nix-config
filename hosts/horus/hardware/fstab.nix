{ ... }:
let
  rootBlockDevice = "/dev/mapper/vg_af4e-lv_sys";
  btrfsOpts = [
    "compress=zstd-1"
    "discard=async"
    "ssd"
  ];
in
{
  services.lvm.enable = true;

  fileSystems = {
    "/" = {
      device = rootBlockDevice;
      fsType = "btrfs";
      options = [
        "subvol=@root-latest"
        "noatime"
        "nosuid"
      ]
      ++ btrfsOpts;
    };
    "/nix" = {
      device = rootBlockDevice;
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "noatime"
        "nodev"
      ]
      ++ btrfsOpts;
    };
    "/persist" = {
      device = rootBlockDevice;
      fsType = "btrfs";
      neededForBoot = true; # for impermanence
      # require suid for distrobox <2024-02-22>
      options = [
        "subvol=@persist"
        "noatime"
        "nodev"
      ]
      ++ btrfsOpts;
    };
    "/home" = {
      device = rootBlockDevice;
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "noatime"
        "nodev"
        "nosuid"
      ]
      ++ btrfsOpts;
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/75402fff-c509-49ef-bf60-b41139242e4a";
      fsType = "vfat";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "noexec"
        "fmask=0077"
        "dmask=0077"
      ];
    };
    # for sops
    "/secrets" = {
      device = rootBlockDevice;
      neededForBoot = true; # mount this path before `system.activationScripts`
      fsType = "btrfs";
      options = [
        "subvol=@secrets"
        "noatime"
        "nodev"
        "nosuid"
      ]
      ++ btrfsOpts;
    };
  };

  rollback-btrfs-root.rootBlockDevice = rootBlockDevice;

  swapDevices = [
    {
      device = "/dev/mapper/vg_af4e-lv_swap";
      options = [ "nofail" ];
      priority = 1;
    }
  ];
}
