{ pkgs, ... }:
{
  environment.defaultPackages = with pkgs; [
    # block-level
    cryptsetup

    # gpt
    gptfdisk # cgdisk

    # progs
    btrfs-progs
    e2fsprogs
    exfatprogs
    f2fs-tools
    udftools
    dosfstools # mkfs.vfat

    # fuse
    cifs-utils
    sshfs

    # access physical device's firmware, ...
    smartmontools
    hddtemp
    nvme-cli
    sedutil # for OPAL NVMe

    # other utils
    compsize # calculate btrfs compressed size
  ];
}
