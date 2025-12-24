{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    cryptsetup
    gptfdisk # sgdisk
    lvm2
    parted # partprobe
    mdadm

    btrfs-progs
    dosfstools
  ];
}
