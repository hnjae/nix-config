/*
  NOTE: deploy-rs 에서 작동 안됨. sudo password 요구 <2025-01-31>
  README:
    nixos-rebuild --target-host 와 deploy-rs 에서 사용할 계정을 생성합니다.

    extraRules 를 정밀하게 작성하려고 하였으나, 잘 안된다. <2025-01-30>
*/
{ localFlake, ... }:
{ pkgs, ... }:
{
  users.users.deploy = {
    isSystemUser = true;
    group = "deploy";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      # 다른 키 사용?
      localFlake.constants.homeSshPublic
    ];
    # To use deploy-rs, a home directory must be set up.
    home = "/var/lib/deploy";
    createHome = true;
  };
  users.groups.deploy = { };

  # PermitTTY no
  services.openssh.extraConfig = ''
    Match User deploy
      AllowAgentForwarding no
      AllowTcpForwarding no
      PermitTunnel no
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
        /*
          NOTE:
            deploy-rs 는 /nix/store/<>/activate-rs 를 실행시킴
            TODO: 작동 확인 필요.

            nixos-rebuild --target-host 는 다음의 커맨드를 sudo 로 실행 시킴
              /run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER= --collect --no-ask-password --pipe --quiet --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait true
              /run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER= --collect --no-ask-password --pipe --quiet --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait /nix/store/<>/bin/switch-to-configuration boot
        */
        # {
        #   command = "/nix/store/*/activate-rs";
        #   options = [ "NOPASSWD" ];
        # }
        # {
        #   command = "/run/current-system/sw/bin/nix-env";
        #   options = [ "NOPASSWD" ];
        # }
        # {
        #   command = "/run/current-system/sw/bin/systemd-run";
        #   options = [ "NOPASSWD" ];
        # }
      ];
    }
  ];
}
