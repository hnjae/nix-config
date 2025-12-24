# NOTE: `efibootmgr` 안써도, UEFI 가 알아서 인식 <2025-12-24>
# TODO: `/boot` 이 업데이트되는 모든 조건에서 이 스크립트가 실행되는지?
{
  pkgs,
  lib,
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
      rsync -aHAXWEs --numeric-ids --delete \
        --exclude='lost+found' \
        -- '/boot/' "$target"
    }

    main () {
      if ! mountpoint -q -- "/boot"; then
        echo "<3>ERROR: '/boot' is not mounted."
        return 1
      fi

      sync_boot "/boot_fallback_a/"
      sync_boot "/boot_fallback_b/"
    }

    main
  '';
in
{
  systemd.services."${serviceName}" = {
    description = "Sync EFI system partition for redundancy";
    wantedBy = [
      "multi-user.target"
      "nixos-generation-gc.service"
    ];
    after = [
      "nixos-generation-gc.service"
      "local-fs.target"
      (self.shared.lib.mountpathToUnit "/boot_fallback_a")
      (self.shared.lib.mountpathToUnit "/boot_fallback_b")
    ];
    wants = [
      (self.shared.lib.mountpathToUnit "/boot_fallback_a")
      (self.shared.lib.mountpathToUnit "/boot_fallback_b")
    ];
    unitConfig = {
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
