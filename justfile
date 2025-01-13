alias t := test
alias fmt := format

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

show-homeConfigurations:
    nix eval \
      --no-warn-dirty \
      --json \
      ".#homeConfigurations" \
      --apply builtins.attrNames | \
      jq '.[]'

show-homeManagerModules:
    nix eval \
      --no-warn-dirty \
      --json \
      ".#homeManagerModules" \
      --apply builtins.attrNames | \
      jq '.[]'

test-flake:
  #!/bin/sh
  set -e

  NIXPKGS_ALLOW_UNFREE=1
  nix flake archive --no-warn-dirty
  nix flake check \
    --no-warn-dirty \
    --all-systems \
    --impure # to check unfree packages

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

drybuild-nixos-desktop:
  nix build \
    --dry-run \
    --no-warn-dirty \
    --option eval-cache false \
    --no-print-missing \
    --quiet \
    --json \
    --builders "" \
    ".#nixosConfigurations.dekstop.config.system.build.toplevel"

drybuild-nixos-desktop-plasma6:
  nix build \
    --dry-run \
    --no-warn-dirty \
    --option eval-cache false \
    --no-print-missing \
    --quiet \
    --json \
    --builders "" \
    ".#nixosConfigurations.dekstop-plasma6-unfree.config.system.build.toplevel"

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

build-home:
  #!/bin/sh
  set -e
  hmName="$(hostname)"

  nix build \
    --no-print-missing \
    --option keep-env-derivations true \
    --option pure-eval true \
    --json \
    --builders "" \
    ".#homeConfigurations.${hmName}.activationPackage"

switch-home:
  #!/bin/sh
  set -e
  hmName="$(hostname)"

  nix build \
    --no-link \
    --no-print-missing \
    --option keep-env-derivations true \
    --option pure-eval true \
    --json \
    --builders "" \
    ".#homeConfigurations.${hmName}.activationPackage"
  bash "$(nix eval --raw ".#homeConfigurations.${hmName}.activationPackage")/activate"


test: test-flake drybuild-homes
