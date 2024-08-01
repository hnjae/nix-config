{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
in {
  virtualisation.libvirtd = {
    enable = mkOverride 999 (! config.boot.isContainer);
    qemu.swtpm.enable = true;
    qemu.ovmf.packages = with pkgs; [OVMFFull.fd];
  };
  # virtualisation.libvirtd.onShutdown = "shutdown";
}
