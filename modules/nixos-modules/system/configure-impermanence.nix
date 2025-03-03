# impermanence 사용할때, stateful 로 사용할 내용 설정
# NOTE: run `nixos-rebuild switch` (not boot) when enabling impermanence.
# `switch` will create persist path for you
{
  lib,
  config,
  ...
}:
let
  cfg = config.persist;
in
{
  options.persist = {
    enable = lib.mkEnableOption (lib.mDoc "");
    path = lib.mkOption {
      type = lib.types.path;
      default = "/persist";
      description = lib.mdDoc "";
    };
    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    isRootNotZFS = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.persistence."${cfg.path}" = {
      hideMounts = true;
      files = builtins.concatLists [
        [
          "/etc/machine-id" # 644
        ]
        (
          # 644
          lib.lists.optional (config.services.displayManager.sddm.enable) "/var/lib/sddm/state.conf"
        )
        # "/var/.updated"
      ];
      directories = builtins.concatLists [
        [
          {
            directory = "/var/log";
            mode = "0755";
          }
          {
            directory = "/var/lib/nixos";
            mode = "0755";
          }
        ]
        [
          {
            directory = "/etc/ssh";
            mode = "755";
          }
        ]
        [
          (
            if config.persist.isDesktop then
              {
                directory = "/var/lib/systemd";
                mode = "0755";
              }
            # persist 가 보존이 안된다.
            else
              {
                directory = "/var/lib/systemd/coredump";
                mode = "0755";
              }

          )
        ]
        (lib.lists.optional (config.services.accounts-daemon.enable) {
          directory = "/var/lib/AccountsService";
          mode = "0755";
        })
        (lib.lists.optional (config.networking.networkmanager.enable) {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        })
        (lib.lists.optional (config.services.fprintd.enable) {
          directory = "/var/lib/fprint";
          mode = "0700";
        })
        (lib.lists.optional (config.virtualisation.waydroid.enable) {
          directory = "/var/lib/waydroid";
          mode = "0755";
        })
        (
          # lib.lists.optional ((builtins.hasAttr "lanzaboote" config.boot) && config.boot.lanzaboote.enable)
          # 그냥 항상 유효화 <2024-11-19>
          [
            {
              directory = "/etc/secureboot";
              mode = "0755"; # checked sbctl's default <NixOS 23.11>
            }
          ])
        (lib.lists.optional ((builtins.hasAttr "lact" config.programs) && config.programs.lact.enable) {
          directory = "/etc/lact";
          mode = "0755"; # checked lact's default <NixOS 24.05>
        })
        (lib.lists.optional (config.hardware.bluetooth.enable) {
          directory = "/var/lib/bluetooth";
          mode = "0700";
        })
        (lib.lists.optional (config.virtualisation.docker.enable && cfg.isRootNotZFS) {
          directory = "/var/lib/docker";
          mode = "0710";
        })
        (lib.lists.optional (config.virtualisation.podman.enable && cfg.isRootNotZFS) {
          directory = "/var/lib/containers";
          mode = "0700";
        })
        (lib.lists.optional (config.virtualisation.libvirtd.enable && cfg.isRootNotZFS) {
          directory = "/var/lib/libvirt";
          mode = "0755";
        })
        (lib.lists.optional (config.services.tailscale.enable) {
          directory = "/var/lib/tailscale";
          mode = "0700";
        })
        # (
        #   lib.lists.optional (config.services.flatpak.enable)
        #   {
        #     directory = "/var/lib/flatpak";
        #     mode = "0755";
        #   }
        # )
      ];
    };
  };
}
