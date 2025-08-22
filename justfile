# check: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix

hostname := `hostname`

_:
    @just --list

[group('git')]
commit:
    #!/bin/sh

    set -eu

    if git diff --cached --quiet --exit-code; then
        echo "Nothing to commit."
        exit 0
    fi

    echo ""
    git -c color.ui=always diff --staged --compact-summary
    echo ""

    echo "> commit? [y/Any]: " > /dev/stderr

    stty -icanon -echo
    eval "response=$(dd bs=1 count=1 2>/dev/null)"
    stty icanon echo

    echo ""

    case "$response" in
    "y") ;; # catch
    *)
            echo "O.k., not committing."
            exit 0
            ;;
    esac

    git commit --no-verify -m '{{ hostname }}: {{ datetime("%Y-%m-%dT%H:%M:%S%Z") }}'

[group('git')]
sync: format
    #!/bin/sh

    set -eu

    just format
    git add --all

    echo ""
    git -c color.ui=always status --short --untracked-files=all --find-renames=y
    echo ""

    echo "> sync? [y/Any]: " > /dev/stderr

    stty -icanon -echo
    eval "response=$(dd bs=1 count=1 2>/dev/null)"
    stty icanon echo

    echo ""

    case "$response" in
    "y") ;; # catch
    *)
            echo "O.k., not syncing."
            exit 0
            ;;
    esac

    git commit --no-verify -m '{{ hostname }}: {{ datetime("%Y-%m-%dT%H:%M:%S%Z") }}'
    git push

alias fmt := format

format:
    nix fmt --no-warn-dirty

[group('update')]
open-status:
    xdg-open "https://status.nixos.org/"

[group('update')]
update:
    nix flake update
    git reset
    git add flake.lock
    git commit -m "build: update flake.lock"

[group('update')]
update-except-unstable:
    #!/usr/bin/env nu

    let inputs = (
        nix flake metadata --json
        | from json
        | $in.locks.nodes.root.inputs
        | columns
        | where $it not-in ["nixpkgs-unstable"]
    )

    nix flake update ...$inputs

    git reset
    git add flake.lock
    git commit -m "build: update flake.lock"

[group('update')]
update-except-stable:
    #!/usr/bin/env nu

    let inputs = (
        nix flake metadata --json
        | from json
        | $in.locks.nodes.root.inputs
        | columns
        | where $it not-in ["nixpkgs"]
    )

    nix flake update ...$inputs

    git reset
    git add flake.lock
    git commit -m "build: update flake.lock"

[group('update')]
[private]
update-local-repo:
    nix flake update py-utils

[group('check')]
remote-build-test: update-local-repo
    nix build \
        --no-link \
        --option eval-cache false \
        --show-trace \
        --max-jobs 0 \
        -vvvvvvvvv \
        ".#nixosConfigurations.horus.config.system.build.toplevel"

#################################################################################
# check recipes

[group('check')]
check: update-local-repo _check-flake _drybuild-homes

[group('check')]
_check-flake:
    #!/bin/sh

    set -eu

    NIXPKGS_ALLOW_UNFREE=1
    nix flake check \
        --no-warn-dirty \
        --impure # to check unfree packages

[group('check')]
_parallel-drybuild-homes-wip:
    #!/bin/sh

    nix eval \
        --no-warn-dirty \
        --json \
        ".#homeConfigurations" \
        --apply builtins.attrNames |
        jq '.[]' |
        parallel --jobs {{ num_cpus() }} \
        "echo '{}' && nix build \
            --dry-run \
            --no-warn-dirty \
            --no-print-missing \
            --option keep-env-derivations true \
            --option pure-eval true \
            --option show-trace false \
            --quiet \
            --json \
            '.#homeConfigurations.{}.activationPackage' 2> >(sed '/^[[:space:]]*\/nix\/store\//d')"

[group('check')]
_drybuild-homes:
    #!/bin/sh

    for home in $(
        nix eval \
            --no-warn-dirty \
            --json \
            ".#homeConfigurations" \
            --apply builtins.attrNames |
            jq '.[]'
    ); do
        target=".#homeConfigurations.${home}.activationPackage"
        echo "Dry-building ${target}"

        nix build \
            --dry-run \
            --no-warn-dirty \
            --no-print-missing \
            --option keep-env-derivations true \
            --option pure-eval true \
            --option show-trace false \
            --quiet \
            "${target}"

        echo ""
    done

# slower than nix flake check

[group('check')]
_drybuild-nixoses: update-local-repo
    #!/bin/sh

    set -eu

    for os in $(
        nix flake show --json 2>/dev/null |
        jq '.nixosConfigurations | to_entries[] | .key' |
        sed 's/"//g'
    ); do
        target=".#nixosConfigurations.${os}.config.system.build.toplevel"
        echo "Dry building ${target}"

        nix build \
            --dry-run \
            --no-warn-dirty \
            --option eval-cache false \
            --no-print-missing \
            --quiet \
            --json \
            "${target}"

        echo ""
    done

################################################################################
# Deploy recipes

[doc('deploy to host using deplory-rs (will rollback if error)')]
[group('deploy')]
[positional-arguments]
@deploy host: update-local-repo
    deploy --keep-result --skip-checks ".#$1"

[doc('deploy to host using nixos-rebuild (will NOT rollback)')]
[group('deploy')]
[positional-arguments]
@deploy-switch host: update-local-repo
    nixos-rebuild switch \
        --flake ".#$1" \
        --target-host "deploy@${1}" \
        --sudo

deploy-horus: update-local-repo
    nixos-rebuild switch \
        --flake ".#horus" \
        --target-host "deploy@192.168.0.200" \
        --sudo

[group('deploy')]
[positional-arguments]
@deploy-boot host: update-local-repo
    nixos-rebuild boot \
        --flake ".#$1" \
        --target-host "deploy@${1}" \
        --sudo

[group('build')]
[positional-arguments]
@build host: update-local-repo
    @echo "Building .#nixosConfigurations.{{ host }}.config.system.build.toplevel"
    nix build \
        --no-link \
        --option eval-cache false \
        --show-trace \
        --keep-failed \
        ".#nixosConfigurations.${1}.config.system.build.toplevel"

[group('build')]
[positional-arguments]
@build-local host: update-local-repo
    @echo "Building .#nixosConfigurations.{{ host }}.config.system.build.toplevel"
    nix build \
        --no-link \
        --option eval-cache false \
        --show-trace \
        --option builders "" \
        --keep-failed \
        ".#nixosConfigurations.${1}.config.system.build.toplevel"

[group('build')]
build-iso: update-local-repo
    nix build .#nixosConfigurations.iso.config.system.build.isoImage

[group('check')]
[positional-arguments]
@drybuild host: update-local-repo
    @echo "Dry-building .#nixosConfigurations.${1}.config.system.build.toplevel"
    nix build \
        --dry-run \
        --option eval-cache false \
        --show-trace \
        ".#nixosConfigurations.${1}.config.system.build.toplevel"

################################################################################
# show flake.outputs

[group('status')]
show:
    nix flake show 2>/dev/null

[group('status')]
show-hm-modules:
    nix eval \
        --no-warn-dirty \
        --json \
        ".#homeManagerModules" \
        --apply builtins.attrNames | \
        jq '.[]'

[group('status')]
show-hm-configurations:
    nix eval \
        --no-warn-dirty \
        --json \
        ".#homeConfigurations" \
        --apply builtins.attrNames | \
        jq '.[]'

################################################################################
# switch/boot local nixos

[group('self-deploy')]
switch-nixos: update-local-repo
    @echo "Switch .#{{ hostname }}"
    sudo nixos-rebuild switch \
        --flake ".#{{ hostname }}" \
        --keep-failed

[group('self-deploy')]
boot-nixos: update-local-repo
    @echo "Build .#{{ hostname }} and register to bootloader"
    sudo nixos-rebuild boot \
        --flake ".#{{ hostname }}" \
        --option eval-cache false \
        --keep-failed

# --builders "" \
# [group('self-deploy')]
# switch-nixos-nh: update-local-repo
#     nh os switch .
# [group('build')]
# build-nixos-nh: update-local-repo
#     nh os build .
################################################################################
# home-manager build/switch

[group('build')]
build-home: update-local-repo
    @echo "Switch home-manager .#{{ hostname }}"
    nix build \
        --no-print-missing \
        --option keep-env-derivations true \
        --option pure-eval true \
        --json \
        ".#homeConfigurations.{{ hostname }}.activationPackage"

[group('self-deploy')]
switch-home: update-local-repo
    #!/bin/sh
    set -eu

    nix build \
        --no-link \
        --no-print-missing \
        --option keep-env-derivations true \
        --option pure-eval true \
        --json \
        ".#homeConfigurations.{{ hostname }}.activationPackage"

    bash "$(nix eval --raw ".#homeConfigurations.{{ hostname }}.activationPackage")/activate"

[linux]
flatpak-sync:
    #!/bin/sh
    systemctl --user start flatpak-managed-install.service &
    journalctl --follow --user --unit=flatpak-managed-install.service
