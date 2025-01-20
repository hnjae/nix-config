{lib, ...}: let
  swapDevice = "/dev/disk/by-partlabel/ISIS_SWAP";
in {
  swapDevices = [
    {
      # https://access.redhat.com/ko/solutions/744483
      device = swapDevice;
      priority = 1;
      # discardPolicy = "once"; # whole swapspace is discarded
      discardPolicy = "pages";
      options = ["nofail"];
      randomEncryption = false; # isis uses opal nvme
    }
  ];
  boot.resumeDevice = swapDevice;
  boot.kernelParams = [
    "resume=LABEL=ISIS_SWAP"
  ];

  # 아래 옵션은 hibernate 를 막음
  # `boot.kernelParams = [ "nohibernate" ];` 를 커널파라미터에 추가한다.
  # https://discourse.nixos.org/t/hibernate-doesnt-work-anymore/24673/6
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/security/misc.nix#L118
  security.protectKernelImage = lib.mkForce false;
  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;
}
