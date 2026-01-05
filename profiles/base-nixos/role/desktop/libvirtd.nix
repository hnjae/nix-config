{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOverride;
  cfg = config.base-nixos;
in
{
  config = lib.mkIf (cfg.role == "desktop" && cfg.hostType == "baremetal") {
    users.users.hnjae.packages = [
      pkgs.virt-manager
      (lib.hiPrio (
        pkgs.runCommandLocal "virt-manager-icon-fix" { } ''
          mkdir -p "$out/share/icons/hicolor/scalable/apps/"

          app_id='virt-manager'
          icon="${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/scalable/apps/''${app_id}.svg"

          cp --reflink=auto \
            "$icon" \
            "$out/share/icons/hicolor/scalable/apps/''${app_id}.svg"

          for size in 16 22 24 32 48 64 96 128 256 512; do
            mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps/"

            '${pkgs.librsvg}/bin/rsvg-convert' \
              --keep-aspect-ratio \
              --height="$size" \
              --output="$out/share/icons/hicolor/''${size}x''${size}/apps/''${app_id}.png" \
              "$icon"
          done
        ''
      ))
    ];
    virtualisation.libvirtd = {
      enable = mkOverride 999 true;
      qemu.swtpm.enable = true;
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
  };
}
