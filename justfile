alias fmt := format

# check: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix

hostname := `hostname`

default:
    @just --list

format:
    nix fmt --no-warn-dirty

open-status:
    xdg-open "https://status.nixos.org/"

update-except-unstable:
    nix flake update \
        nixpkgs \
        flake-parts \
        flake-utils \
        home-manager \
        impermanence \
        microvm \
        nix-flatpak \
        nix-index-database \
        nix-web-app \
        ghostty \
        nixpkgs-mozilla \
        nixvim \
        nur \
        rust-overlay \
        base16 \
        base16-schemes \
        base24-vscode-terminal

update:
    nix flake update

update-local-repo:
    nix flake update nix-modules-private

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
@deploy-rs host: update-local-repo
    deploy --keep-result --skip-checks -d ".#$1"

# Use `NIX_SSHOPTS="-o RequestTTY=force"` to type sudo password

# --target-host "deploy@${1}.local" \
[positional-arguments]
@deploy-switch host: update-local-repo
    nixos-rebuild switch \
        --flake ".#$1" \
        --target-host "deploy@${1}.local" \
        --use-remote-sudo

[positional-arguments]
@deploy-boot host: update-local-repo
    nixos-rebuild boot \
        --flake ".#$1" \
        --target-host "deploy@${1}.local" \
        --use-remote-sudo

[positional-arguments]
@build host: update-local-repo
    @echo "Dry-building .#nixosConfigurations.<host>.config.system.build.toplevel"
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
        --no-link \
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

################################################################################
# nh

switch-os-nh: update-local-repo
    nh os switch .

build-os-hn: update-local-repo
    nh os build .
