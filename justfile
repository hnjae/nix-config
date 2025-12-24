# check: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix

set ignore-comments := true

hostname := `hostname`
project := `basename $(pwd)`
system := `nix --extra-experimental-features nix-command eval --raw --impure --expr builtins.currentSystem`

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
[positional-arguments]
update-except input=`echo "nixpkgs-unstable"`:
    #!/usr/bin/env nu

    let inputs = (
        nix flake metadata --json
        | from json
        | $in.locks.nodes.root.inputs
        | columns
        | where $it not-in ["{{ input }}"]
    )

    nix flake update ...$inputs

    git reset
    git add flake.lock
    git commit -m "build: update flake.lock"

[group('update')]
[private]
update-locals:
    #!/bin/sh

    SCRIPT="./hosts/eris/serve-encrypted/services/traefik/shared/update-cloudflare-ips.sh"

    if [ "$(file --brief -- "$SCRIPT")" != "data" ]; then
        "$SCRIPT"
    else
        echo "{{ BOLD }}{{ BLUE }}INFO: Skipping update-cloudflare-ips.sh since it is locked (encrypted).{{ NORMAL }}" >&2
    fi

[group('check')]
remote-build-test: update-locals
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
check:
    NIXPKGS_ALLOW_UNFREE=1 nix flake check --no-warn-dirty

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
_drybuild-nixoses: update-locals
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

[group('check')]
[positional-arguments]
@drybuild host:
    just build "{{ host }}" "--dry"

################################################################################
# Deploy recipes

[doc('deploy to host using deplory-rs (will rollback if error)')]
[group('deploy')]
[positional-arguments]
@deploy host: update-locals
    deploy --keep-result --skip-checks ".#$1"

[doc('deploy to host using deploy-rs (will NOT rollback)')]
[group('deploy')]
[positional-arguments]
@deploy-switch host: update-locals
    deploy --keep-result --skip-checks --magic-rollback false --auto-rollback=false ".#$1"

[doc('deploy to host using deploy-rs and register to bootloader (will NOT rollback)')]
[group('deploy')]
[positional-arguments]
@deploy-boot host: update-locals
    deploy --keep-result --skip-checks --boot ".#$1"

[group('deploy')]
[positional-arguments]
@deploy-manual host ip: update-locals
    nixos-rebuild switch \
        --flake ".#$1" \
        --target-host "deploy@$2" \
        --sudo

################################################################################
# Build recipes

[group('build')]
[positional-arguments]
build host=`hostname` flags='': update-locals
    #!/bin/sh

    set -eu

    build_nixos() {
        host="$1"
        target="nixosConfigurations.${host}.config.system.build.toplevel"
        outlink="/nix/var/nix/gcroots/per-user/${USER}/{{ project }}#${target}"

        echo ""
        if [ '{{ flags }}' = "" ]; then
            echo "{{ BOLD }}{{ BLUE }}INFO: Building .#${target} {{ NORMAL }}" >&2
        else
            echo "{{ BOLD }}{{ BLUE }}INFO: Building .#${target} with {{ flags }} flags{{ NORMAL }}" >&2
        fi

        if command -v nh >/dev/null 2>&1; then
            nh os build --hostname="${host}" \
                --keep-failed \
                --out-link "$outlink" \
                .
        else
            nix --extra-experimental-features "nix-command flakes" \
                build \
                {{ flags }} \
                --out-link "$outlink" \
                --option eval-cache false \
                --show-trace \
                --keep-failed \
                ".#${target}"
        fi
    }

    main() {
        if [ "{{ host }}" = "all" ]; then
            hosts=$(nix flake show --json --no-pretty 2>/dev/null | jq -r '.nixosConfigurations | keys[]')

            for h in $hosts; do
                build_nixos "$h"
            done
        else
            build_nixos "{{ host }}"
        fi
    }

    main

[group('build')]
build-home: update-locals
    @echo "Building .#homeConfigurations.{{ hostname }}.activationPackage"
    nix build \
        --no-print-missing \
        --option keep-env-derivations true \
        --option pure-eval true \
        --json \
        ".#homeConfigurations.{{ hostname }}.activationPackage"

[group('build')]
build-iso: update-locals
    nix build ".#nixosConfigurations.iso.config.system.build.isoImage"

[group('build')]
build-packages: update-locals
    #!/bin/sh

    set -eu

    build() {
        target="$1"

        echo "{{ BOLD }}{{ BLUE }}INFO: Building ${target}{{ NORMAL }}" >&2

        nix build \
            --out-link "/nix/var/nix/gcroots/per-user/${USER}/{{ project }}#${target}" \
            --option eval-cache false \
            --show-trace \
            --keep-failed \
            ".#${target}"
    }

    main() {
        for pkg in $(
            nix flake show --json --no-pretty 2>/dev/null |
            jq -r '.packages."{{ system }}" | keys[]'
        ); do
            build "packages.{{ system }}.${pkg}"
        done
    }

    main

[group('build')]
build-others:
    #!/bin/sh

    set -eu

    build() {
        target="$1"

        echo "{{ BOLD }}{{ BLUE }}INFO: Building ${target}{{ NORMAL }}" >&2

        nix build \
            --out-link "/nix/var/nix/gcroots/per-user/${USER}/{{ project }}#${target}" \
            --option eval-cache false \
            --show-trace \
            --keep-failed \
            ".#${target}"
    }

    main() {
        build "formatter.{{ system }}"

        for pkg in $(
            nix flake show --json --no-pretty 2>/dev/null |
            jq -r '.devShells."{{ system }}" | keys[]'
        ); do
            build "devShells.{{ system }}.${pkg}"
        done
    }

    main

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
        --no-pretty \
        ".#homeManagerModules" \
        --apply builtins.attrNames | \
        jq '.[]'

[group('status')]
show-hm-configurations:
    nix eval \
        --no-warn-dirty \
        --json \
        --no-pretty \
        ".#homeConfigurations" \
        --apply builtins.attrNames | \
        jq '.[]'

################################################################################
# switch/boot local nixos

[group('self-deploy')]
switch-nixos: update-locals
    @echo "Switch .#{{ hostname }}"
    sudo nixos-rebuild switch \
        --flake ".#{{ hostname }}" \
        --keep-failed

[group('self-deploy')]
boot-nixos: update-locals
    @echo "Build .#{{ hostname }} and register to bootloader"
    sudo nixos-rebuild boot \
        --flake ".#{{ hostname }}" \
        --option eval-cache false \
        --keep-failed

################################################################################
# home-manager build/switch

[group('self-deploy')]
switch-home: update-locals
    #!/bin/sh

    set -eu

    nix build \
        --no-link \
        --out-link "/nix/var/nix/gcroots/per-user/$USER/nixosConfigurations.${1}.config.system.build.toplevel" \
        --no-print-missing \
        --option keep-env-derivations true \
        --option pure-eval true \
        --json \
        ".#homeConfigurations.{{ hostname }}.activationPackage"

    bash "$(nix eval --raw ".#homeConfigurations.{{ hostname }}.activationPackage")/activate"
