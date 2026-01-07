{ lib, ... }:
{
  services.rpcbind.enable = lib.mkForce false; # NixOS 25.11 에서 자동 enable. vers4 를 사용하니 필요X

  # man:nfs.conf(5)
  # https://man7.org/linux/man-pages/man5/nfs.conf.5.html
  services.nfs.settings = {
    nfsd = {
      udp = false;
      tcp = true;
      rdma = true; # RDMA 지원 NIC 필요.
      threads = 12;

      # 아래는 대충 설정
      lease-time = 90; # 클라이언트가 살아 있다고 서버가 믿어주는 시간
      grace-time = 180; # 서버 재시작 후, 기존 클라이언트가 락을 되찾을 수 있는 시간

      vers3 = false;
      "vers4.0" = false;
      "vers4.1" = false;
      "vers4.2" = true;
    };
  };

  # will run `nfs-server.service`
  services.nfs.server = {
    nproc = 12;
    enable = true;
    # NOTE: 서로 다른 btrfs subvolume 을 여러번 export 할때 fsid=uuid 필요한듯.
    exports =
      let
        opts = builtins.concatStringsSep "," [
          "rw"
          "async"
          "no_subtree_check"
          "all_squash,anonuid=1000,anongid=100"
          "fsid=022439b3-5f06-4df3-97e6-7cf0cdf2c8f8"
        ];
      in
      ''
        /home/hnjae 100.64.0.0/10(${opts})
      '';
  };
}
