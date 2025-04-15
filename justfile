alias fmt := format

# check: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix

hostname := `hostname`

default:
    @just --list

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

sync: format
    #!/bin/sh

    set -eu

    git add --all

    echo ""
    git -c color.ui=always status --short --untracked-files=all --find-renames=y
    echo ""

    echo "> sync? [Y/Any]: " > /dev/stderr

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

format:
    nix fmt --no-warn-dirty

open-status:
    xdg-open "https://status.nixos.org/"

update:
    nix flake update
    git reset
    git add flake.lock
    git commit -m "build: update flake.lock"

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

update-local-repo:
    nix flake update nix-modules-private py-utils

# TODO: 아래를 activation script 에 넣기 <2025-02-18>
pre-home-manager-switch:
    #!/bin/sh
    set -eu

    file="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list.backup"
    if [ -f "$file" ]; then
        if command -v trash >/dev/null 2>&1; then
            trash -- "$file"
        else
            rm -- "$file"
        fi
    fi

drybuild-homes-wip:
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

build-iso:
    nix build .#nixosConfigurations.nixos-iso.config.system.build.isoImage

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

_check-flake:
    #!/bin/sh
    set -eu

    NIXPKGS_ALLOW_UNFREE=1
    nix flake check \
        --no-warn-dirty \
        --impure # to check unfree packages

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

        # nix eval \
        #   --raw \
        #   --no-warn-dirty \
        #   --option eval-cache true \
        #   --quiet \
        #   "${target}"

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

check: update-local-repo _check-flake _drybuild-homes

################################################################################
# Deploy recipes

[positional-arguments]
@deploy host: update-local-repo
    deploy --keep-result --skip-checks ".#$1"

[positional-arguments]
@deploy-switch host: update-local-repo
    nixos-rebuild switch \
        --flake ".#$1" \
        --target-host "deploy@${1}" \
        --use-remote-sudo

[positional-arguments]
@deploy-boot host: update-local-repo
    nixos-rebuild boot \
        --flake ".#$1" \
        --target-host "deploy@${1}" \
        --use-remote-sudo

[positional-arguments]
@build host: update-local-repo
    @echo "Building .#nixosConfigurations.<host>.config.system.build.toplevel"
    nix build \
        --no-link \
        --option eval-cache false \
        --show-trace \
        ".#nixosConfigurations.${1}.config.system.build.toplevel"

[positional-arguments]
@drybuild host: update-local-repo
    @echo "Dry-building .#nixosConfigurations.<host>.config.system.build.toplevel"
    nix build \
        --dry-run \
        --option eval-cache false \
        --show-trace \
        ".#nixosConfigurations.${1}.config.system.build.toplevel"

################################################################################
# show flake.outputs

show:
    nix flake show 2>/dev/null

show-hm-modules:
    nix eval \
        --no-warn-dirty \
        --json \
        ".#homeManagerModules" \
        --apply builtins.attrNames | \
        jq '.[]'

show-hm-configurations:
    nix eval \
        --no-warn-dirty \
        --json \
        ".#homeConfigurations" \
        --apply builtins.attrNames | \
        jq '.[]'

################################################################################
# nixos-rebuild

switch-nixos: pre-home-manager-switch update-local-repo
    @echo "Switch .#{{ hostname }}"
    sudo nixos-rebuild switch \
        --flake ".#{{ hostname }}" \
        --keep-failed

boot-nixos: pre-home-manager-switch update-local-repo
    @echo "Build .#{{ hostname }} and register to bootloader"
    sudo nixos-rebuild boot \
        --flake ".#{{ hostname }}" \
        --option eval-cache false \
        --keep-failed

drybuild-nixos: update-local-repo
    @echo "Dry-building .#nixosConfigurations.{{ hostname }}.config.system.build.toplevel"
    nix build \
        --dry-run \
        --option eval-cache false \
        --show-trace \
        ".#nixosConfigurations.{{ hostname }}.config.system.build.toplevel"

build-nixos: update-local-repo
    @echo "Building .#nixosConfigurations.{{ hostname }}.config.system.build.toplevel"
    nix build \
        --option eval-cache false \
        --show-trace \
        --keep-failed \
        ".#nixosConfigurations.{{ hostname }}.config.system.build.toplevel"

# slower than nix flake check
drybuild-nixoses: update-local-repo
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
# home-manager build/switch

build-home: update-local-repo
    @echo "Switch home-manager .#{{ hostname }}"
    nix build \
        --no-print-missing \
        --option keep-env-derivations true \
        --option pure-eval true \
        --json \
        ".#homeConfigurations.{{ hostname }}.activationPackage"

switch-home: update-local-repo pre-home-manager-switch
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

################################################################################
# nh

switch-os-nh: update-local-repo pre-home-manager-switch
    nh os switch .

build-os-nh: update-local-repo
    nh os build .
