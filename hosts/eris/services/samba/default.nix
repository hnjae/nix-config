{
  pkgs,
  config,
  ...
}:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    # https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
    settings = {
      global = {
        "hosts allow" = builtins.concatStringsSep " " [
          "100.64.0.0/10" # 100.[64-127]
          "127.0.0.1"
          "localhost"
        ];

        "hosts deny" = "0.0.0.0/0";
        "printable" = "no";

        "security" = "user";
        "valid users" = "hnjae";
        "server smb encrypt" = "off"; # use wireguard only
        # "server services" = "-dns -dnsupdate";
      };
    };
  };

  sops.secrets =
    let
      stat = {
        sopsFile = ./secrets/default.yaml;
        format = "yaml";
        restartUnits = [ "samba-user-setup" ];
      };
    in
    {
      smb-user-password = stat;
      smb-user-credentials = stat;
    };

  systemd.services.samba-user-setup =
    let
      passwdFile = config.sops.secrets.smb-user-password.path;
    in
    {
      description = "Setup samba user";
      partOf = [ "samba.target" ];
      wantedBy = [ "samba.target" ];
      after = [ "samba-smbd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "set-samba-password" ''
          #!${pkgs.dash}/bin/dash

          set -eu

          PATH="${pkgs.coreutils}/bin:${pkgs.samba}/bin"

          (cat '${passwdFile}'; cat '${passwdFile}') | pdbedit -a -u hnjae -t
        '';
        RemainAfterExit = true;
      };
      unitConfig = {
        ConditionPathExists = passwdFile;
        ConditionFileNotEmpty = passwdFile;
        RequiresMountsFor = "/var/lib/samba";
      };
    };

  /*
    NOTE:

      참고자료: <https://discourse.nixos.org/t/nixos-configuration-for-samba/17079/6>

      #### passdb backend 종류
        - tdbsam password 서버가 필요한 종류
        - smbpasswd 기존 samba password
        - ldapsam ldap 베이스
  */
}
