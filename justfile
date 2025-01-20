alias t := test
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

test-flake:
  #!/bin/sh
  set -e

  NIXPKGS_ALLOW_UNFREE=1
  nix flake archive --no-warn-dirty
  nix flake check \
    --no-warn-dirty \
    --all-systems \
    --impure # to check unfree packages

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

drybuild-homes:
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
      --json \
      --builders "" \
      "${target}"

    echo ""
  done

# slower than nix flake check
drybuild-nixoses:
  #!/bin/sh
  set -e

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
      --builders "" \
      "${target}"

    echo ""
  done

build-iso:
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

test: test-flake drybuild-homes

################################################################################
# show flake.outputs
################################################################################

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
################################################################################
switch-nixos: pre-home-manager-switch
  @echo "Switch .#{{hostname}}"
  sudo nixos-rebuild switch \
    --flake ".#{{hostname}}" \
    --keep-failed

boot-nixos:
  @echo "Build .#{{hostname}} and register to bootloader"
  sudo nixos-rebuild boot \
    --flake ".#{{hostname}}" \
    --option eval-cache false \
    --keep-failed

drybuild-nixos:
  @echo "Dry building NixOS .#{{hostname}}"
  nixos-rebuild \
    dry-build \
    --option warn-dirty false \
    --option eval-cache false \
    --show-trace \
    --impure \
    --flake ".#{{hostname}}"

build-nixos:
  @echo "Building .#nixosConfigurations.{{hostname}}.config.system.build.toplevel"
  nix build \
    --no-link \
    --option eval-cache false \
    --show-trace \
    --keep-failed \
    ".#nixosConfigurations.{{hostname}}.config.system.build.toplevel"

################################################################################
# home-manager build/switch
################################################################################
build-home:
  @echo "Switch home-manager .#{{hostname}}"
  nix build \
    --no-print-missing \
    --option keep-env-derivations true \
    --option pure-eval true \
    --json \
    ".#homeConfigurations.{{hostname}}.activationPackage"

switch-home:
  #!/bin/sh
  set -eu

  nix build \
    --no-link \
    --no-print-missing \
    --option keep-env-derivations true \
    --option pure-eval true \
    --json \
    ".#homeConfigurations.{{hostname}}.activationPackage"

  bash "$(nix eval --raw ".#homeConfigurations.{{hostname}}.activationPackage")/activate"
