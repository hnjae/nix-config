{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  cfg = config.generic-nixos;
in {
  virtualisation.libvirtd = {
    enable = mkOverride 999 (cfg.role != "vm");
    qemu.swtpm.enable = true;
    qemu.ovmf.packages = with pkgs; [OVMFFull.fd];
  };
  # virtualisation.libvirtd.onShutdown = "shutdown";
}
