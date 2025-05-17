{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOverride;
  cfg = config.base-nixos;
  isDesktop = config.base-nixos.role == "desktop";
in
{
  boot.kernelModules = [ "wireguard" ];

  networking.useDHCP = lib.mkOverride 999 (!isDesktop);

  # The list of nameservers. It can be left empty if it is auto-detected through DHCP.
  networking.nameservers = lib.mkIf (cfg.hostType == "baremetal") (
    mkOverride 999 [
      # "8.8.8.8"
      # "8.8.4.4"
      # "2001:4860:4860::8888"
      # "2001:4860:4860::8844"

      # "1.1.1.1"
      # "1.0.0.1"
      # "2606:4700:4700::1111"
      # "2606:4700:4700::1001"

      # Quad9
      "9.9.9.10"
      "2620:fe::10"
    ]
  );

  services.resolved = {
    # DoH not supported: <2024-08-20>
    # https://github.com/systemd/systemd/issues/8639
    enable = mkOverride 999 (cfg.hostType == "baremetal");
    dnsovertls = mkOverride 999 "true";
    dnssec = mkOverride 999 "allow-downgrade";
    fallbackDns = mkOverride 999 [
      # NOTE: nameserver 가 없고 fallbackDns 가 없으면 resolve 되지 않음.

      # Quad9
      "149.112.112.10"
      "2620:fe::fe:10"
    ];
    llmnr = "resolve";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # nssmdns6 = true;
  };
}
