{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOverride;
  cfg = config.base-nixos;
in
{
  boot.kernelModules = [ "wireguard" ];

  # The list of nameservers. It can be left empty if it is auto-detected through DHCP.
  networking.nameservers = lib.mkIf (cfg.hostType == "baremetal") (
    mkOverride 999 [
      # "1.1.1.1"
      # "1.0.0.1"
      # "2606:4700:4700::1111"
      # "2606:4700:4700::1001"

      # Quad9
      "9.9.9.10"
      "2620:fe::10"
    ]
  );

  /*
    NOTE:

    captive-portal 관련 링크 들?

    - <https://first.wifi.olleh.com/starbucks/index_en.html>
    - <http://detectportal.firefox.com/>
  */

  # DoH not supported: <2024-08-20>
  # https://github.com/systemd/systemd/issues/8639
  services.resolved = {
    enable = mkOverride 999 (cfg.hostType == "baremetal");
    # dnsovertls = mkOverride 999 "true";

    # NOTE: captive-portal 관련 테스트 <2025-09-04>
    dnsovertls = mkOverride 999 "opportunistic"; # "true" 대신 "opportunistic" 사용
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
    enable = mkOverride 999 true;
    nssmdns4 = mkOverride 999 true;
    # nssmdns6 = false;
  };
}
