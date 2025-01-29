{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOverride;
  cfg = config.base-nixos;
in
{
  boot.kernelModules = [ "wireguard" ];

  networking.networkmanager = {
    enable = lib.mkOverride 999 true;
    plugins = with pkgs; [
      networkmanager_strongswan
    ];
  };

  services.dbus.packages = lib.lists.optional config.networking.networkmanager.enable pkgs.strongswanNM;

  # TODO: use host's dns in vm <2024-08-20>
  networking.nameservers = mkOverride 999 [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  # org.freedesktop.resolve1
  services.resolved = {
    # DoH not supported: <2024-08-20>
    # https://github.com/systemd/systemd/issues/8639
    # TODO: use resolved on my servers <2024-08-20>
    enable = mkOverride 999 (cfg.hostType == "baremetal");
    # dnsovertls = mkOverride 999 "opportunistic"; # will fallback
    dnsovertls = mkOverride 999 "true";
    dnssec = mkOverride 999 "allow-downgrade";
    fallbackDns = mkOverride 999 [
      # "9.9.9.9"
      # "149.112.112.112"
      # "2620:fe::9"
      # "2620:fe::fe"

      # "8.8.8.8"
      # "8.8.4.4"
      # "2001:4860:4860::8888"
      # "2001:4860:4860::8844"
    ];
    llmnr = "resolve";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
