# Basic NixOS test for rustic-btrfs module
# Tests that service and timer are properly created
#
# Note: This is a basic smoke test that verifies module structure.
# It does not test actual backup functionality (requires btrfs setup).

import <nixpkgs/nixos/tests/make-test-python.nix> (
  { pkgs, ... }:
  let
    # Create a minimal flake structure for testing
    testFlake = {
      packages.${pkgs.stdenv.hostPlatform.system}.rustic-btrfs = pkgs.writeScriptBin "rustic-btrfs" ''
        #!/bin/sh
        echo "Mock rustic-btrfs for testing"
        exit 0
      '';
    };

    # Import the module with required arguments
    rusticBtrfsModule = import ./nixos-module.nix {
      localFlake = testFlake;
      projectName = "rustic-btrfs";
    };
  in
  {
    name = "rustic-btrfs-basic";

    nodes.machine =
      { config, pkgs, ... }:
      {
        imports = [ rusticBtrfsModule ];

        my.services.rustic-btrfs.backups.test = {
          subvolume = "/test-subvol";
          environmentFile = pkgs.writeText "rustic.env" ''
            RUSTIC_REPOSITORY=/tmp/test-repo
            RUSTIC_PASSWORD=test
          '';
          timerConfig.OnCalendar = "daily";
        };
      };

    testScript = ''
      machine.start()

      # Check service exists
      machine.succeed("systemctl list-unit-files | grep rustic-btrfs-test.service")

      # Check timer exists and is enabled
      machine.succeed("systemctl is-enabled rustic-btrfs-test.timer")

      # Check restic user was created
      machine.succeed("id restic")

      # Check lock directory exists
      machine.succeed("test -d /run/lock/rustic-btrfs")

      # Note: Not testing actual backup (requires btrfs filesystem setup)
    '';
  }
)
