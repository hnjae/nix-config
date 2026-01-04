# NOTE: `efibootmgr` 안써도, UEFI 가 알아서 인식 <2025-12-24>
# TODO: `/boot` 이 업데이트되는 모든 조건에서 이 스크립트가 실행되는지?
{
  pkgs,
  lib,
  config,
  self,
  ...
}:
let
  serviceName = "sync-esp";
  script = pkgs.writeScript serviceName ''
    #!${pkgs.dash}/bin/dash

    set -eu

    PATH="${
      lib.makeBinPath [
        pkgs.util-linux # mountpoint
        pkgs.rsync
      ]
    }"

    sync_boot () {
      target="$1"

      if ! mountpoint -q -- "$target"; then
        echo "<3>ERROR: Target '$target' is not mounted."
        return 1
      fi

      # /boot의 내용을 다른 EFI 파티션에 복사
      if rsync -aHAXWEs --numeric-ids --delete --exclude='lost+found' -- '/boot/' "$target"; then
        echo "<6>INFO: Sync to $target successful."
      else
        echo "<3>ERROR: rsync failed for $target with exit code $?"
        return 1
      fi

      return 0
    }

    main () {
      if ! mountpoint -q -- "/boot"; then
        echo "<3>ERROR: '/boot' is not mounted."
        return 1
      fi

      exit_status=0
      sync_boot "/boot_fallback_a/" || exit_status=1
      sync_boot "/boot_fallback_b/" || exit_status=1

      return "$exit_status"
    }

    main
  '';
in
{
  systemd.services."${serviceName}" = rec {
    description = "Sync EFI system partition for redundancy";

    # NOTE: WantedBy 는 `[Install]` 섹션에 들어감
    wantedBy = lib.flatten [
      "multi-user.target" # after boot
      (lib.lists.optional config.my.services.nixos-gc.enable "nixos-gc.service")
      (lib.lists.optional config.my.services.nix-store-gc.enable "nix-store-gc.service")
      (lib.lists.optional config.nix.gc.automatic "nix-gc.service")
      (lib.lists.optional config.programs.nh.clean.enable "nh-clean.service")
    ];

    unitConfig = rec {
      Wants = [
        (self.shared.lib.mountpathToUnit "/boot_fallback_a")
        (self.shared.lib.mountpathToUnit "/boot_fallback_b")
      ];
      After = lib.flatten [
        wantedBy
        Wants
        "local-fs.target"
      ];
      RequiresMountsFor = "/boot";
    };

    serviceConfig = {
      Type = "oneshot";
      # RemainAfterExit = true;
      Nice = 10;
      IOSchedulingPriority = 7;
      ExecStart = "${script}";
    };
  };

  system.activationScripts."${serviceName}" = {
    text = ''
      "${script}"
    '';
  };
}
