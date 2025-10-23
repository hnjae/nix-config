# NOTE: users.users.main 식으로 정의하고 `name` attribute 로 유저명을 정의해서 사용하면 impermanence 에서 활용이 안됨. <NixOS 23.11>
{ localFlake, ... }:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.base-nixos;
in
{
  security.sudo.wheelNeedsPassword = lib.mkOverride 999 false;

  users.mutableUsers = false;
  users.defaultUserShell = lib.mkOverride 999 pkgs.zsh;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      # TODO: disable ssh login? <2025-02-03>
      localFlake.shared.keys.ssh.home
    ];
    hashedPassword = "$y$j9T$s.YA/IM9krcOc4J..OIke1$s0tKPmYDPljrwee8fho0q5w6bMq1YhG9uKDk.O5S6U2";
  };

  users.users.hnjae = {
    isNormalUser = true;
    extraGroups = lib.flatten [
      "wheel"
      (lib.lists.optional (
        config.services.locate.enable && (lib.hasPrefix "plocate" config.services.locate.package.name)
      ) "plocate")
      (lib.lists.optionals (cfg.role == "desktop") (
        lib.flatten [
          # NOTE: docker/podman 을 유저가 sudo 없이 실행하는건 bad practice 임
          (lib.lists.optional config.networking.networkmanager.enable "networkmanager")
          (lib.lists.optional config.hardware.i2c.enable "i2c")
          (lib.lists.optional config.programs.adb.enable "adbusers")
          (lib.lists.optional config.virtualisation.libvirtd.enable "libvirtd")
          (lib.lists.optionals config.hardware.sane.enable [
            "scanner"
            "lp"
          ])
        ]
      ))
    ];
    uid = 1000;
    shell = pkgs.zsh;

    # NOTE: run mkpasswd to get hashedPassword
    hashedPassword = "$y$j9T$sWlQsKkeQ0haWP/7Ki4Jh.$rTiCZXpbBixRPOdSZqki6EoIEcvfKOAPn1iUaBSm5.6";
    description = "KIM Hyunjae";
    openssh.authorizedKeys.keys = [
      localFlake.shared.keys.ssh.home
    ];

    # true: start systemd user unit at boot, not login
    linger = false;
  };

  # your gpg-key should be as same as you user key
  # security.pam.services."hnjae".gnupg.enable = true;
}
