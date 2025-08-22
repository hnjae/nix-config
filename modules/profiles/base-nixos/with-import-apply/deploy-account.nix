/*
  README:
    nixos-rebuild --target-host 와 deploy-rs 에서 사용할 계정을 생성합니다.

    deploy-rs 는 /nix/store/<>/activate-rs 와 /tmp/deploy-rs-* 를 root 권한으로 실행시킴

    해당 경로를 NOPASSWD 로 허락하면, 임의로 /tmp 에 스크립트를 작성해 실행시키는 방법을 사용할 수 있다. 때문에 NOPASSWD 로 실행 바이너리를 제한하는 것이 의미가 없다.
*/
{ localFlake, ... }:
{ pkgs, ... }:
{
  users.users.deploy = {
    isSystemUser = true;
    group = "deploy";
    shell = pkgs.dash;
    openssh.authorizedKeys.keys = [
      # 다른 키 사용?
      localFlake.shared.keys.ssh.home
    ];
    # To use deploy-rs, a home directory must be set up.
    home = "/var/lib/deploy";
    createHome = true;
  };
  users.groups.deploy = { };

  services.openssh.extraConfig = ''
    Match User deploy
      AllowAgentForwarding no
      AllowTcpForwarding no
      PermitTunnel no
      PermitTTY no
      X11Forwarding no
    Match All
  '';

  nix.settings.trusted-users = [ "deploy" ];

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
