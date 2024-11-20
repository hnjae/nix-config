{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOverride;
  cfg = config.generic-nixos;
in {
  config = lib.mkIf (cfg.role != "vm") {
    virtualisation.libvirtd = {
      enable = mkOverride 999 (cfg.role != "vm");
      qemu.swtpm.enable = true;
      qemu.ovmf.packages = with pkgs; [OVMFFull.fd];
    };

    home-manager.sharedModules = [
      {
        xdg.configFile."libvirt/qemu.conf" = {
          text = ''
            nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
          '';
        };
      }
    ];
    # virtualisation.libvirtd.onShutdown = "shutdown";
  };
}
