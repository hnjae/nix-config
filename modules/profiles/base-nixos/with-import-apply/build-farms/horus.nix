{ localFlake, ... }:
{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName != "horus") {
    # TODO: serve /nix <2025-02-04>

    # nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem
    # sops.secrets.horus-binary-cache-pub-key = {
    #   format = "binary";
    #   sopsFile = ./secrets/horus-nix-store-binary-cache-pub-key.pem;
    #   mode = "0444";
    # };

    # TODO: key is corrupt 뜸 <2024-12-14>
    # nix.settings.trusted-public-keys = [
    #   "${config.sops.secrets.horus-binary-cache-pub-key.path}"
    # ];

    # NOTE: use trusted-substituters instead of substitutes cause of server can go down <2024-12-14>
    # nix.settings.trusted-substituters = [
    #   "ssh-ng://"
    # ];
    # nix.settings.substituters = [
    #   "ssh-ng://"
    # ];

    nix.buildMachines = [
      (
        localFlake.constants.hosts.horus.buildMachine
        // {
          sshUser = "nix-ssh";
          /*
            NOTE: (NixOS 24.11)
              * `sshKey` 값은 무시되고, /root/.ssh/id_ed25519 가 쓰임 <2024-12-14>
              * 혹시나 해서 /root/.ssh/ 아래의 다른 경로를 테스트 해보았는데 작동 안됨 <2024-12-17>
                * 시험 해본 값:
                  * /run/secrets/nix-ssh-priv-key
                  * /root/.ssh/nix-ssh-id_ed25519
                  * /root/.ssh/id_nixssh_ed25519
          */
          sshKey = "/root/.ssh/id_ed25519";
          protocol = "ssh-ng";
        }
      )
    ];

    # TODO: declaratvie knownHosts <2025-02-04>
    # `SHA256:` 로 시작하는 값을 요구하는 것 같음 <2025-02-04>
    # programs.ssh.knownHosts.horus = {
    #   publicKey = localFlake.constants.hosts.horus.sshPublicKey;
    #   hostNames = [ localFlake.constants.hosts.horus.buildMachine.hostName ];
    # };
  };
}
