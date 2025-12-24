#!/usr/bin/env bash

set -xeuo pipefail

HOSTNAME_="eris"
DISK_2203="/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b49c9e525"
DISK_3926="/dev/disk/by-id/nvme-nvme.1e4b-3330313632333433393236-48532d5353442d465554555245203430393647-00000001" # almost new
DISK_3090="/dev/disk/by-id/nvme-nvme.1e4b-3330313333323833303930-48532d5353442d465554555245203430393647-00000001"

format() {
  local name="$1"
  local disk="$2"

  if [ ! -b "$disk" ]; then
    echo "ERROR: Disk $disk not found" >&2
    exit 1
  fi

  echo "INFO: Starting disk formatting of $disk"
  echo ""

  sgdisk --zap-all "$disk"
  sgdisk --clear "$disk"
  partprobe "$disk"

  sgdisk --align-end --new=1:0:+4G --partition-guid=1:R --change-name=1:"${name}_ESP" --typecode=1:EF00 "$disk"
  partprobe "$disk"
  udevadm trigger --subsystem-match=block
  udevadm settle --timeout 120

  sgdisk --align-end --new=2:0:-0 --partition-guid=2:R --change-name=2:"${name}_LUKS" --typecode=2:8309 "$disk"
  partprobe "$disk"
  udevadm trigger --subsystem-match=block
  udevadm settle --timeout 120

  mkfs.fat -F 32 -n "${name^^}_ESP" -S 4096 "${disk}-part1"

  cryptsetup \
    --type luks2 \
    --cipher "aes-xts-plain64" \
    --label "${name}_LUKS" \
    --key-size "256" \
    --sector-size "4096" \
    --use-urandom \
    luksFormat \
    "${disk}-part2"

  cryptsetup luksOpen --allow-discards --persistent --perf-no_read_workqueue --perf-no_write_workqueue "${disk}-part2" "luks_${name}"

  pvcreate "/dev/mapper/luks_${name}"
  vgcreate "vg_${name}" "/dev/mapper/luks_${name}"
  lvcreate --size "4G" --name "swap" "vg_${name}"

  mkswap --pagesize 4096 --label "${name}_SWAP" "/dev/vg_${name}/swap"
}

main() {
  format "2203" "$DISK_2203"
  format "3926" "$DISK_3926"
  format "3090" "$DISK_3090"

  lvcreate --size "896G" --name "$HOSTNAME_" "vg_2203"
  lvcreate --size "1024G" --name "$HOSTNAME_" "vg_3090"
  lvcreate --size "1024G" --name "$HOSTNAME_" "vg_3926"

  mkfs.btrfs --sectorsize 4096 \
    --metadata raid1c3 --data raid1 \
    --label "${HOSTNAME_^^}_OS" \
    -O block-group-tree \
    /dev/vg_2203/"$HOSTNAME_" \
    /dev/vg_3090/"$HOSTNAME_" \
    /dev/vg_3926/"$HOSTNAME_"

  local osblock="/dev/disk/by-label/${HOSTNAME_^^}_OS"

  mount --mkdir "$osblock" /mnt2
  btrfs subvolume create /mnt2/@nix
  btrfs subvolume create /mnt2/@zlocal
  btrfs subvolume create /mnt2/@zsafe
  btrfs subvolume create /mnt2/@srv
  umount /mnt2
  rmdir /mnt2

  mount --mkdir -o noatime,mode=0755 -t tmpfs tmpfs /mnt
  mount --mkdir -o nodev,nosuid,noatime,noacl,compress=zstd:11,nodiscard,subvol=@nix "$osblock" /mnt/nix
  mount --mkdir -o nodev,nosuid,noatime,noacl,compress=zstd:11,nodiscard,subvol=@zlocal "$osblock" /mnt/zlocal
  mount --mkdir -o nodev,nosuid,noatime,noacl,compress=zstd:11,nodiscard,subvol=@zsafe "$osblock" /mnt/zsafe
  mount --mkdir -o nodev,nosuid,noatime,noacl,compress=zstd:11,nodiscard,subvol=@srv "$osblock" /mnt/srv

  mount --mkdir -o noatime,nodev,nosuid,noexec,fmask=0077,dmask=0077 "/dev/disk/by-label/3926_ESP" /mnt/boot

  # mdadm --create /dev/md/ESP --metadata="1.0" --level=1 --raid-disks=3 \
  #   "/dev/disk/by-partlabel/2203_ESP" \
  #   "/dev/disk/by-partlabel/3926_ESP" \
  #   "/dev/disk/by-partlabel/3090_ESP"
  #
  # mkfs.fat -F 32 -n "${HOSTNAME_^^}_ESP" -S 4096 /dev/md/ESP
  # mount --mkdir -o nofail,noatime,nodev,nosuid,noexec,fmask=0077,dmask=0077 "/dev/label/${HOSTNAME_}_ESP" /mnt/boot
  #
  # mdadm --detail --scan | tee -a mdadm-out.conf
  # e.g.: ARRAY /dev/md/eris_ESP metadata=1.0 UUID=e5bbacee:f8139782:7e91a98f:1702e91b
}

main
